import 'dart:async';

import 'package:cqrs/cqrs.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:force_update/data/contracts/contracts.dart';
import 'package:force_update/src/force_update_storage.dart';
import 'package:force_update/src/app_version.dart';
import 'package:in_app_update/in_app_update.dart';
import 'package:logging/logging.dart';
import 'package:package_info_plus/package_info_plus.dart';

class ForceUpdateGuard extends StatefulWidget {
  const ForceUpdateGuard({
    super.key,
    required this.cqrs,
    required this.suggestUpdateDialog,
    required this.forceUpdateScreen,
    this.useAndroidSystemUI = false,
    this.androidSystemUILoadingIndicator,
    required this.dialogContextKey,
    required this.child,
  });

  final Cqrs cqrs;
  final Widget suggestUpdateDialog;
  final Widget forceUpdateScreen;
  final bool useAndroidSystemUI;
  final Widget? androidSystemUILoadingIndicator;
  final GlobalKey dialogContextKey;
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
  Timer? _checkForEnforcedUpdateTimer;

  final _logger = Logger('ForceUpdateGuard');

  @override
  void initState() {
    super.initState();

    init();
  }

  Future<void> init() async {
    _packageInfo = await PackageInfo.fromPlatform();

    _updateVersionsInfo();

    _checkForEnforcedUpdateTimer = Timer.periodic(
      ForceUpdateGuard.updateCheckingInterval,
      (_) => _updateVersionsInfo(),
    );

    final mostRecentForceUpdateResult = await _storage.readMostRecentResult();
    final currentVersion = AppVersion(version: _packageInfo.version);

    if (mostRecentForceUpdateResult == null ||
        mostRecentForceUpdateResult.versionAtTimeOfRequest < currentVersion) {
      return;
    }

    force.value = mostRecentForceUpdateResult.result ==
        VersionSupportResultDTO.updateRequired;

    if (mostRecentForceUpdateResult.result ==
        VersionSupportResultDTO.updateSuggested) {
      if (widget._actuallyUseAndroidSystemUI) {
        await InAppUpdate.checkForUpdate();
        await InAppUpdate.startFlexibleUpdate();
        return InAppUpdate.completeFlexibleUpdate();
      }

      final context = widget.dialogContextKey.currentContext;

      // ignore: use_build_context_synchronously
      if (context == null || !context.mounted) {
        _logger.warning(
          'Failed to show SuggestUpdateDialog: context is null or not mounted',
        );

        return;
      }

      return showDialog(
        context: context,
        builder: (context) => widget.suggestUpdateDialog,
      );
    }
  }

  Future<void> _updateVersionsInfo() async {
    _logger.info('Looking for updates...');

    try {
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

      await _storage.writeResult(ForceUpdateResult(
        versionAtTimeOfRequest: AppVersion(version: _packageInfo.version),
        result: response.result,
      ));
    } catch (e, st) {
      _logger.info('Failed to fetch updates info', e, st);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: force,
      child: widget.child,
      builder: (context, force, child) {
        if (force != true) {
          return child!;
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
    _checkForEnforcedUpdateTimer?.cancel();

    super.dispose();
  }
}
