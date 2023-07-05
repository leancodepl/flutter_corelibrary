import 'package:debug_page/debug_page.dart';
import 'package:debug_page/src/logger_listener.dart';
import 'package:debug_page/src/ui/logs_inspector/logger/logs_inspector_logger_tab.dart';
import 'package:debug_page/src/ui/logs_inspector/requests/logs_inspector_requests_tab.dart';
import 'package:debug_page/src/ui/typography.dart';
import 'package:flutter/material.dart';

class LogsInspector extends StatefulWidget {
  const LogsInspector({
    super.key,
    required LoggingHttpClient loggingHttpClient,
    required LoggerListener loggerListener,
  })  : _loggingHttpClient = loggingHttpClient,
        _loggerListener = loggerListener;

  final LoggingHttpClient _loggingHttpClient;
  final LoggerListener _loggerListener;

  @override
  State<StatefulWidget> createState() {
    return _LogsInspectorState();
  }
}

class _LogsInspectorState extends State<LogsInspector> {
  bool showFilters = false;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Logs inspector'),
          actions: [
            IconButton(
              icon: const Icon(Icons.tune),
              onPressed: () => setState(() => showFilters = !showFilters),
            )
          ],
          bottom: TabBar(
            labelStyle: DebugPageTypography.medium,
            tabs: const [
              Text('Requests'),
              Text('Logs'),
            ],
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.only(top: 16),
          child: TabBarView(
            children: [
              LogsInspectorRequestsTab(
                loggingHttpClient: widget._loggingHttpClient,
                showFilters: showFilters,
              ),
              LogsInspectorLoggerTab(loggerListener: widget._loggerListener),
            ],
          ),
        ),
      ),
    );
  }
}
