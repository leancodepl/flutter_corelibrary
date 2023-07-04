import 'package:debug_page/debug_page.dart';
import 'package:debug_page/src/logger_listener.dart';
import 'package:flutter/material.dart';
import 'package:shake/shake.dart';

class DebugPage {
  DebugPage({required LoggingHttpClient loggingHttpClient}) {
    _shakeDetector = ShakeDetector.autoStart(
      shakeThresholdGravity: 1.5,
      onPhoneShake: () async {
        if (debugPageOn) {
          return;
        }

        debugPageOn = true;

        await _navigatorKey.currentState?.push(
          MaterialPageRoute(
            builder: (context) => DebugScreen(
              loggingHttpClient: loggingHttpClient,
              loggerListener: _loggerListener,
            ),
          ),
        );

        debugPageOn = false;
      },
    );
  }

  final _navigatorKey = GlobalKey<NavigatorState>();

  final LoggerListener _loggerListener = LoggerListener();
  late ShakeDetector _shakeDetector;

  bool debugPageOn = false;

  GlobalKey<NavigatorState> getNavigatorKey() => _navigatorKey;

  void dispose() {
    _loggerListener.dispose();
    _shakeDetector.stopListening();
  }
}
