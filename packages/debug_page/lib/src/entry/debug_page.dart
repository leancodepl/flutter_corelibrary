import 'package:debug_page/debug_page.dart';
import 'package:debug_page/src/logger_listener.dart';
import 'package:flutter/material.dart';
import 'package:shake/shake.dart';

class DebugPage {
  DebugPage({required LoggingHttpClient loggingHttpClient})
      : _loggingHttpClient = loggingHttpClient {
    _shakeDetector = ShakeDetector.autoStart(
      shakeThresholdGravity: 1.5,
      onPhoneShake: () {
        final context = debugPageOverlayState.currentContext;

        if (context == null) {
          return;
        }

        show(context);
      },
    );
  }

  final LoggingHttpClient _loggingHttpClient;
  final LoggerListener _loggerListener = LoggerListener();
  late ShakeDetector _shakeDetector;

  OverlayEntry? _overlayEntry;

  Future<void> show(BuildContext context) async {
    if (_overlayEntry != null) {
      return;
    }

    _overlayEntry = OverlayEntry(
      builder: (context) => DebugScreen(
        loggingHttpClient: _loggingHttpClient,
        loggerListener: _loggerListener,
        onBackButtonClicked: () {
          _overlayEntry?.remove();
          _overlayEntry = null;
        },
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  void dispose() {
    _loggerListener.dispose();
    _shakeDetector.stopListening();
  }
}
