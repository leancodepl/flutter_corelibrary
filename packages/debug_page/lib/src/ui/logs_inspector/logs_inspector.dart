import 'package:debug_page/debug_page.dart';
import 'package:debug_page/src/logger_listener.dart';
import 'package:debug_page/src/ui/logs_inspector/filters_menu.dart';
import 'package:debug_page/src/ui/logs_inspector/logger/logs_inspector_logger_tab.dart';
import 'package:debug_page/src/ui/logs_inspector/requests/logs_inspector_requests_tab.dart';
import 'package:debug_page/src/ui/typography.dart';
import 'package:flutter/material.dart';

class _Bottom extends StatelessWidget implements PreferredSizeWidget {
  _Bottom({required this.expanded});

  final bool expanded;

  final _tabBar = TabBar(
    labelStyle: DebugPageTypography.medium,
    tabs: const [
      Text('Requests'),
      Text('Logs'),
    ],
  );

  @override
  Size get preferredSize => expanded
      ? _tabBar.preferredSize + const Offset(0, FiltersMenu.height)
      : Size.zero;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (expanded)
          const SizedBox(
            height: FiltersMenu.height,
            child: FiltersMenu(),
          ),
        _tabBar,
      ],
    );
  }
}

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
          bottom: _Bottom(expanded: showFilters),
        ),
        body: TabBarView(
          children: [
            LogsInspectorRequestsTab(
              loggingHttpClient: widget._loggingHttpClient,
            ),
            LogsInspectorLoggerTab(loggerListener: widget._loggerListener),
          ],
        ),
      ),
    );
  }
}
