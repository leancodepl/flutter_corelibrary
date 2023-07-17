import 'dart:async';

import 'package:cqrs/cqrs.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:force_update/data/contracts/contracts.dart';
import 'package:force_update/src/force_update_storage.dart';
import 'package:force_update/src/ui/force_update_screen.dart';
import 'package:force_update/src/app_version.dart';
import 'package:logging/logging.dart';
import 'package:package_info_plus/package_info_plus.dart';

class ForceUpdateResponse {
  const ForceUpdateResponse({required this.minRequiredVersion});

  final String minRequiredVersion;
}

class ForceUpdateGuard<T> extends StatefulWidget {
  const ForceUpdateGuard({
    super.key,
    required this.cqrs,
    required this.child,
  });

  final Cqrs cqrs;
  final Widget child;

  static const updateCheckingInterval = Duration(minutes: 5);

  @override
  State<ForceUpdateGuard<T>> createState() => _ForceUpdateGuardState<T>();
}

class _ForceUpdateGuardState<T> extends State<ForceUpdateGuard<T>> {
  _ForceUpdateGuardState() : _storage = ForceUpdateStorage();

  final ForceUpdateStorage _storage;
  late PackageInfo _packageInfo;
  final force = ValueNotifier<bool?>(null);
  Timer? _checkForEnforcedUpdateTimer;

  final _logger = Logger('ForceUpdateGuard');

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

      final minRequiredVersion = AppVersion(
        version: response.minimumRequiredVersion,
      );

      await _storage.writeMinRequiredVersion(minRequiredVersion);
    } catch (e, st) {
      _logger.info('Failed to fetch updates info', e, st);
    }
  }

  @override
  void initState() {
    super.initState();

    init();
  }

  Future<void> init() async {
    _packageInfo = await PackageInfo.fromPlatform();
    final minRequiredVersion = await _storage.readMinRequiredVersion();
    final currentVersion = AppVersion(version: _packageInfo.version);

    force.value =
        minRequiredVersion != null && currentVersion < minRequiredVersion;

    _updateVersionsInfo();

    _checkForEnforcedUpdateTimer = Timer.periodic(
      ForceUpdateGuard.updateCheckingInterval,
      (timer) => _updateVersionsInfo(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: force,
      builder: (context, force, child) {
        if (force == true) {
          return const ForceUpdateScreen();
        }

        return child!;
      },
      child: widget.child,
    );
  }

  @override
  void dispose() {
    _checkForEnforcedUpdateTimer?.cancel();

    super.dispose();
  }
}
