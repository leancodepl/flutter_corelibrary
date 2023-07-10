import 'package:debug_page/src/core/debug_page_controller.dart';
import 'package:debug_page/src/ui/colors.dart';
import 'package:debug_page/src/ui/logs_inspector/logger/logs_inspector_logger_tab.dart';
import 'package:debug_page/src/ui/logs_inspector/requests/logs_inspector_requests_tab.dart';
import 'package:debug_page/src/ui/logs_inspector/widgets/logs_inspector_share_button.dart';
import 'package:debug_page/src/ui/typography.dart';
import 'package:flutter/material.dart';

enum LogsInspectorTab {
  requests,
  logs,
}

class LogsInspector extends StatefulWidget {
  const LogsInspector({
    super.key,
    required DebugPageController controller,
    required VoidCallback onBackButtonClicked,
  })  : _controller = controller,
        _onBackButtonClicked = onBackButtonClicked;

  final DebugPageController _controller;
  final VoidCallback _onBackButtonClicked;

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
        floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
        floatingActionButton: LogsInspectorShareButton(
          controller: widget._controller,
        ),
        appBar: AppBar(
          leading: BackButton(onPressed: widget._onBackButtonClicked),
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
        body: Column(
          children: [
            Container(
              color: DebugPageColors.background,
              width: double.infinity,
              height: 16,
            ),
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
