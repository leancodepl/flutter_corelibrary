import 'package:flutter/material.dart';
import 'package:leancode_debug_page/leancode_debug_page.dart';
import 'package:leancode_debug_page/src/ui/debug_page_route.dart';
import 'package:leancode_debug_page/src/ui/logs_inspector/logger/logs_inspector_logger_tab.dart';
import 'package:leancode_debug_page/src/ui/logs_inspector/requests/logs_inspector_requests_tab.dart';
import 'package:leancode_debug_page/src/ui/logs_inspector/widgets/logs_inspector_share_button.dart';
import 'package:leancode_debug_page/src/ui/typography.dart';

enum LogsInspectorTab {
  requests,
  logs,
}

class LogsInspectorRoute extends DebugPageRoute {
  LogsInspectorRoute(DebugPageController controller)
      : super(
          builder: (context) => LogsInspector(controller: controller),
        );
}

class LogsInspector extends StatefulWidget {
  const LogsInspector({
    super.key,
    required DebugPageController controller,
  }) : _controller = controller;

  final DebugPageController _controller;

  @override
  State<StatefulWidget> createState() {
    return _LogsInspectorState();
  }
}

class _LogsInspectorState extends State<LogsInspector> {
  bool showFilters = false;

  void _clearCurrentTab() {
    final tabController = DefaultTabController.of(context);
    if (tabController.index == 0) {
      widget._controller.clearRequestsLogs();
    } else {
      widget._controller.clearLoggerLogs();
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
        floatingActionButton: LogsInspectorShareButton(
          controller: widget._controller,
        ),
        appBar: AppBar(
          leading: const BackButton(),
          title: const Text('Logs inspector'),
          actions: [
            IconButton(
              icon: const Icon(Icons.clear),
              tooltip: 'Clear logs',
              onPressed: _clearCurrentTab,
            ),
            IconButton(
              icon: const Icon(Icons.tune),
              onPressed: () => setState(() => showFilters = !showFilters),
            ),
          ],
          bottom: TabBar(
            labelPadding: const EdgeInsets.only(bottom: 8),
            labelStyle: DebugPageTypography.medium,
            tabs: const [
              Text('Requests'),
              Text('Logs'),
            ],
          ),
        ),
        body: Column(
          children: [
            Expanded(
              child: TabBarView(
                children: [
                  LogsInspectorRequestsTab(
                    controller: widget._controller,
                    showFilters: showFilters,
                  ),
                  LogsInspectorLoggerTab(
                    controller: widget._controller,
                    showFilters: showFilters,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
