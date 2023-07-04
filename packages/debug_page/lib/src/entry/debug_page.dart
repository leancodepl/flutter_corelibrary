import 'package:debug_page/debug_page.dart';
import 'package:debug_page/src/logger_listener.dart';
import 'package:flutter/material.dart';
import 'package:shake/shake.dart';

class DebugPage {
  DebugPage({required LoggingHttpClient loggingHttpClient})
      : _loggingHttpClient = loggingHttpClient {
    _shakeDetector = ShakeDetector.autoStart(
      shakeThresholdGravity: 1.5,
      onPhoneShake: show,
    );
  }

  final _navigatorKey = GlobalKey<NavigatorState>();

  final LoggingHttpClient _loggingHttpClient;
  final LoggerListener _loggerListener = LoggerListener();
  late ShakeDetector _shakeDetector;

  bool shown = false;

  GlobalKey<NavigatorState> getNavigatorKey() => _navigatorKey;

  Future<void> show() async {
    if (shown) {
      return;
    }

    shown = true;

    await _navigatorKey.currentState?.push<void>(
      MaterialPageRoute(
        builder: (context) => DebugScreen(
          loggingHttpClient: _loggingHttpClient,
          loggerListener: _loggerListener,
        ),
      ),
    );

    shown = false;
  }

  void dispose() {
    _loggerListener.dispose();
    _shakeDetector.stopListening();
  }
}
