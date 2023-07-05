import 'package:debug_page/debug_page.dart';
import 'package:debug_page/src/logger_listener.dart';
import 'package:debug_page/src/ui/logs_inspector/logs_inspector.dart';
import 'package:flutter/material.dart';

class DebugScreen extends StatelessWidget {
  const DebugScreen({
    super.key,
    required LoggingHttpClient loggingHttpClient,
    required LoggerListener loggerListener,
    required this.onBackButtonClicked,
  })  : _loggingHttpClient = loggingHttpClient,
        _loggerListener = loggerListener;

  final LoggingHttpClient _loggingHttpClient;
  final LoggerListener _loggerListener;
  final VoidCallback onBackButtonClicked;

  @override
  Widget build(BuildContext context) {
    return LogsInspector(
      loggingHttpClient: _loggingHttpClient,
      loggerListener: _loggerListener,
      onBackButtonClicked: onBackButtonClicked,
    );
  }
}
