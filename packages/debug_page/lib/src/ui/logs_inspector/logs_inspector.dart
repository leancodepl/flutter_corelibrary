import 'package:debug_page/debug_page.dart';
import 'package:debug_page/src/logger_listener.dart';
import 'package:debug_page/src/ui/logs_inspector/logs_inspector_logger_tab.dart';
import 'package:debug_page/src/ui/logs_inspector/logs_inspector_requests_tab.dart';
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
          leading: BackButton(
            onPressed: Navigator.of(context, rootNavigator: true).pop,
          ),
          title: const Text('Debug page'),
        ),
        body: Column(
          children: [
            const TabBar(
              tabs: [
                Text('Requests'),
                Text('Logs'),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  LogsInspectorRequestsTab(
                      loggingHttpClient: _loggingHttpClient),
                  LogsInspectorLoggerTab(loggerListener: _loggerListener),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
