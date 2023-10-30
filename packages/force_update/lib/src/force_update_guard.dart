import 'dart:async';

import 'package:cqrs/cqrs.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:force_update/data/contracts/contracts.dart';
import 'package:force_update/src/force_update_storage.dart';
import 'package:in_app_update/in_app_update.dart';
import 'package:logging/logging.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:version/version.dart';

class ForceUpdateGuardController extends InheritedWidget {
  const ForceUpdateGuardController({
    super.key,
    required this.onPop,
    required super.child,
  });

  final VoidCallback onPop;

  void hideSuggestDialog() => onPop();

  static ForceUpdateGuardController? maybeOf(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<ForceUpdateGuardController>();
  }

  static ForceUpdateGuardController of(BuildContext context) {
    final result = maybeOf(context);
    assert(result != null, 'No ForceUpdateGuardController found in context');

    return result!;
  }

  @override
  bool updateShouldNotify(covariant ForceUpdateGuardController oldWidget) {
    return false;
  }
}

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
  final Widget child;

  static const updateCheckingInterval = Duration(minutes: 5);

  bool get _actuallyUseAndroidSystemUI =>
      defaultTargetPlatform == TargetPlatform.android && useAndroidSystemUI;

  @override
  State<ForceUpdateGuard> createState() => _ForceUpdateGuardState();
}

class _ForceUpdateGuardState extends State<ForceUpdateGuard> {
  _ForceUpdateGuardState() : _storage = ForceUpdateStorage();

  final ForceUpdateStorage _storage;
  late PackageInfo _packageInfo;
  final force = ValueNotifier<bool?>(null);
  final suggest = ValueNotifier<bool?>(null);
  late Listenable listenable;
  Timer? _checkForEnforcedUpdateTimer;

  final _logger = Logger('ForceUpdateGuard');

  @override
  void initState() {
    super.initState();

    init();
  }

  Future<void> _applyMostRecentResult({required bool conditional}) async {
    final applyResponseIfSuggested =
        !conditional || widget.showSuggestUpdateDialogImmediately;
    final applyResponseIfForce =
        !conditional || widget.showForceUpdateScreenImmediately;

    final mostRecentForceUpdateResult = await _storage.readMostRecentResult();
    final currentVersion = Version.parse(_packageInfo.version);

    if (mostRecentForceUpdateResult == null ||
        mostRecentForceUpdateResult.versionAtTimeOfRequest < currentVersion) {
      return;
    }

    if (applyResponseIfForce) {
      force.value = mostRecentForceUpdateResult.result ==
          VersionSupportResultDTO.updateRequired;
    }

    if (mostRecentForceUpdateResult.result ==
            VersionSupportResultDTO.updateSuggested &&
        applyResponseIfSuggested) {
      if (widget._actuallyUseAndroidSystemUI) {
        await InAppUpdate.checkForUpdate();
        await InAppUpdate.startFlexibleUpdate();
        return InAppUpdate.completeFlexibleUpdate();
      }

      suggest.value = true;
    }
  }

  Future<void> _updateAndMaybeApplyVersionsInfo() async {
    await _updateVersionsInfo();
    return _applyMostRecentResult(conditional: true);
  }

  Future<void> init() async {
    listenable = Listenable.merge([force, suggest]);
    _packageInfo = await PackageInfo.fromPlatform();

    unawaited(_updateAndMaybeApplyVersionsInfo());

    _checkForEnforcedUpdateTimer = Timer.periodic(
      ForceUpdateGuard.updateCheckingInterval,
      (_) => _updateAndMaybeApplyVersionsInfo(),
    );

    return _applyMostRecentResult(conditional: false);
  }

  Future<void> _updateVersionsInfo() async {
    _logger.info('Looking for updates...');

    final platform = switch (defaultTargetPlatform) {
      TargetPlatform.android => PlatformDTO.android,
      TargetPlatform.iOS => PlatformDTO.ios,
      _ => throw StateError('Force update only works for Android & iOS'),
    };

    final response = await widget.cqrs.get(
      VersionSupport(
        platform: platform,
        version: _packageInfo.version,
      ),
    );

    if (response case QuerySuccess(:final data)) {
      await _storage.writeResult(
        ForceUpdateResult(
          versionAtTimeOfRequest: Version.parse(_packageInfo.version),
          result: data.result,
        ),
      );
    } else {
      _logger.info('Failed to fetch updates info');
    }
  }

  @override
  Widget build(BuildContext context) {
    return ForceUpdateGuardController(
      onPop: () => suggest.value = false,
      child: ListenableBuilder(
        listenable: listenable,
        child: widget.child,
        builder: (context, child) {
          if (force.value != true) {
            return Stack(
              alignment: Alignment.center,
              children: [
                child!,
                if (suggest.value ?? false) widget.suggestUpdateDialog,
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
      ),
    );
  }

  @override
  void dispose() {
    _checkForEnforcedUpdateTimer?.cancel();

    super.dispose();
  }
}
