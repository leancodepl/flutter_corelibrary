import 'dart:async';

import 'package:cqrs/cqrs.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:in_app_update/in_app_update.dart';
import 'package:leancode_force_update/data/contracts/contracts.dart';
import 'package:leancode_force_update/src/force_update_storage.dart';
import 'package:logging/logging.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:version/version.dart';

part 'package:leancode_force_update/src/force_update_controller.dart';

class ForceUpdateGuard extends StatefulWidget {
  const ForceUpdateGuard({
    super.key,
    required this.cqrs,
    required this.suggestUpdateDialog,
    required this.forceUpdateScreen,
    this.useAndroidSystemUI = false,
    this.androidSystemUILoadingIndicator,
    this.showForceUpdateScreenImmediately = true,
    this.showSuggestUpdateDialogImmediately = true,
    required this.controller,
    required this.child,
  });

  final Cqrs cqrs;
  final Widget suggestUpdateDialog;
  final Widget forceUpdateScreen;
  final bool useAndroidSystemUI;
  final Widget? androidSystemUILoadingIndicator;

  /// Set this to false to show force update screen on next app launch instead
  /// of showing it immediately once the version support info is obtained
  final bool showForceUpdateScreenImmediately;

  /// Set this to false to show suggest update dialog on next app launch instead
  /// of showing it immediately once the version support info is obtained
  final bool showSuggestUpdateDialogImmediately;
  final ForceUpdateController controller;
  final Widget child;

  static const updateCheckingInterval = Duration(minutes: 5);

  bool get _actuallyUseAndroidSystemUI =>
      defaultTargetPlatform == TargetPlatform.android && useAndroidSystemUI;

  @override
  State<ForceUpdateGuard> createState() => _ForceUpdateGuardState();
}

class _ForceUpdateGuardState extends State<ForceUpdateGuard>
    with WidgetsBindingObserver {
  _ForceUpdateGuardState() : _storage = ForceUpdateStorage();

  final ForceUpdateStorage _storage;
  late PackageInfo _packageInfo;
  final force = ValueNotifier<bool?>(null);
  late Listenable listenable;
  Timer? _checkForEnforcedUpdateTimer;
  var _isAppInForeground = true;
  DateTime? _lastVersionCheckAt;

  final _logger = Logger('ForceUpdateGuard');

  @override
  void initState() {
    super.initState();

    init();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final wasInForeground = _isAppInForeground;
    _syncForegroundFromLifecycle(state);

    if (wasInForeground && !_isAppInForeground) {
      _stopTimer();
    } else if (!wasInForeground && _isAppInForeground) {
      _startTimer();
      _updateIfIntervalElapsed();
    }
  }

  void _syncForegroundFromLifecycle(AppLifecycleState state) {
    _isAppInForeground = state == AppLifecycleState.resumed;
  }

  void _startTimer() {
    _checkForEnforcedUpdateTimer?.cancel();
    _checkForEnforcedUpdateTimer = Timer.periodic(
      ForceUpdateGuard.updateCheckingInterval,
      (_) => _tryForegroundUpdateCheck(),
    );
  }

  void _stopTimer() {
    _checkForEnforcedUpdateTimer?.cancel();
    _checkForEnforcedUpdateTimer = null;
  }

  void _updateIfIntervalElapsed() {
    if (!_isAppInForeground) {
      return;
    }

    if (_lastVersionCheckAt case final lastCheck?
        when DateTime.now().difference(lastCheck) <
            ForceUpdateGuard.updateCheckingInterval) {
      return;
    }

    _tryForegroundUpdateCheck();
  }

  void _tryForegroundUpdateCheck() {
    if (!_isAppInForeground) {
      return;
    }

    _updateAndMaybeApplyVersionsInfo().catchError((dynamic err) {
      _logger.warning('Failed to check for updates', err);
    });
  }

  Future<void> _applyResult({required ForceUpdateResult? result}) async {
    final currentVersion = Version.parse(_packageInfo.version);

    if (result == null || result.versionAtTimeOfRequest < currentVersion) {
      return;
    }

    force.value = result.conclusion == VersionSupportResultDTO.updateRequired;

    if (result.conclusion == VersionSupportResultDTO.updateSuggested) {
      if (widget._actuallyUseAndroidSystemUI) {
        await InAppUpdate.checkForUpdate();
        await InAppUpdate.startFlexibleUpdate();
        return InAppUpdate.completeFlexibleUpdate();
      } else {
        widget.controller._suggest.value = true;
      }
    }
  }

  Future<void> _updateAndMaybeApplyVersionsInfo() async {
    await _updateVersionsInfo();

    final recentResult = await _storage.readMostRecentResult();

    if ((recentResult?.conclusion == VersionSupportResultDTO.updateRequired &&
            widget.showForceUpdateScreenImmediately) ||
        (recentResult?.conclusion == VersionSupportResultDTO.updateSuggested &&
            widget.showSuggestUpdateDialogImmediately)) {
      return _applyResult(result: recentResult);
    }
  }

  Future<void> init() async {
    WidgetsBinding.instance.addObserver(this);
    _syncForegroundFromLifecycle(
      WidgetsBinding.instance.lifecycleState ?? AppLifecycleState.detached,
    );

    listenable = Listenable.merge([force, widget.controller._suggest]);
    _packageInfo = await PackageInfo.fromPlatform();

    if (_isAppInForeground) {
      _startTimer();
    }

    final recentResult = await _storage.readMostRecentResult();
    await _applyResult(result: recentResult);

    _tryForegroundUpdateCheck();
  }

  Future<void> _updateVersionsInfo() async {
    _lastVersionCheckAt = DateTime.now();

    _logger.info('Looking for updates...');

    final platform = switch (defaultTargetPlatform) {
      TargetPlatform.android => PlatformDTO.android,
      TargetPlatform.iOS => PlatformDTO.ios,
      _ => throw StateError('Force update only works for Android & iOS'),
    };

    final response = await widget.cqrs.get(
      VersionSupport(platform: platform, version: _packageInfo.version),
    );

    if (response case QuerySuccess(:final data)) {
      await _storage.writeResult(
        ForceUpdateResult(
          versionAtTimeOfRequest: Version.parse(_packageInfo.version),
          conclusion: data.result,
        ),
      );
    } else {
      _logger.info('Failed to fetch updates info');
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: listenable,
      child: widget.child,
      builder: (context, child) {
        if (force.value != true) {
          return Stack(
            alignment: Alignment.center,
            children: [
              child!,
              if (widget.controller._suggest.value) widget.suggestUpdateDialog,
            ],
          );
        }

        if (!widget._actuallyUseAndroidSystemUI) {
          return widget.forceUpdateScreen;
        }

        return FutureBuilder(
          future: InAppUpdate.checkForUpdate(),
          builder: (context, snapshot) {
            final data = snapshot.data;
            if (data?.immediateUpdateAllowed ?? false) {
              InAppUpdate.performImmediateUpdate();
            }

            return widget.androidSystemUILoadingIndicator ??
                const CircularProgressIndicator();
          },
        );
      },
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _stopTimer();

    super.dispose();
  }
}
