import 'package:debug_page/debug_page.dart';
import 'package:debug_page/src/core/logger_listener.dart';
import 'package:debug_page/src/ui/logs_inspector/logs_inspector.dart';
import 'package:flutter/material.dart';

class DebugPage extends StatefulWidget {
  const DebugPage({
    super.key,
    required LoggingHttpClient loggingHttpClient,
  }) : _loggingHttpClient = loggingHttpClient;

  final LoggingHttpClient _loggingHttpClient;

  @override
  State<DebugPage> createState() {
    return _DebugPageState();
  }
}

class _DebugPageState extends State<DebugPage> {
  _DebugPageState() : _loggerListener = LoggerListener();

  final LoggerListener _loggerListener;

  @override
  Widget build(BuildContext context) {
    return Navigator(
      onGenerateRoute: (_) => MaterialPageRoute(
        builder: (context) => LogsInspector(
          loggingHttpClient: widget._loggingHttpClient,
          loggerListener: _loggerListener,
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();

    _loggerListener.dispose();
  }
}
