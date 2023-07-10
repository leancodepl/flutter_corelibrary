import 'package:debug_page/debug_page.dart';
import 'package:debug_page/src/logger_listener.dart';
import 'package:debug_page/src/ui/logs_inspector/logger/logs_inspector_logger_tab.dart';
import 'package:debug_page/src/ui/logs_inspector/requests/logs_inspector_requests_tab.dart';
import 'package:debug_page/src/ui/typography.dart';
import 'package:flutter/material.dart';

class LogsInspector extends StatelessWidget {
  const LogsInspector({
    super.key,
    required LoggingHttpClient loggingHttpClient,
    required LoggerListener loggerListener,
  })  : _loggingHttpClient = loggingHttpClient,
        _loggerListener = loggerListener;

  final LoggingHttpClient _loggingHttpClient;
  final LoggerListener _loggerListener;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Logs inspector'),
          bottom: TabBar(
            labelStyle: DebugPageTypography.medium,
            tabs: const [
              Text('Requests'),
              Text('Logs'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            LogsInspectorRequestsTab(loggingHttpClient: _loggingHttpClient),
            LogsInspectorLoggerTab(loggerListener: _loggerListener),
          ],
        ),
      ),
    );
  }
}
