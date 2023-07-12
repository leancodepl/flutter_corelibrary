import 'package:debug_page/src/core/debug_page_controller.dart';
import 'package:debug_page/src/models/request_log_record.dart';
import 'package:debug_page/src/ui/logs_inspector/requests/requests_tab_filters_menu.dart';
import 'package:debug_page/src/ui/logs_inspector/requests/request_log_tile.dart';
import 'package:debug_page/src/ui/typography.dart';
import 'package:flutter/material.dart';

class LogsInspectorRequestsTab extends StatelessWidget {
  const LogsInspectorRequestsTab({
    super.key,
    required DebugPageController controller,
    required bool showFilters,
  })  : _controller = controller,
        _showFilters = showFilters;

  final DebugPageController _controller;
  final bool _showFilters;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (_showFilters) RequestsTabFiltersMenu(controller: _controller),
        Expanded(
          child: _LogsInspectorRequestsTabContent(controller: _controller),
        ),
      ],
    );
  }
}

class _LogsInspectorRequestsTabContent extends StatelessWidget {
  const _LogsInspectorRequestsTabContent({
    required DebugPageController controller,
  }) : _controller = controller;

  final DebugPageController _controller;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<RequestLogRecord>>(
      initialData: _controller.requestsLogs,
      stream: _controller.requestsLogStream,
      builder: (context, snapshot) {
        final logs = snapshot.data;

        if (logs == null || logs.isEmpty == true) {
          return _EmptyPlaceholder();
        }

        return ListView(
          children: ListTile.divideTiles(
            context: context,
            tiles: logs.reversed.map(
              (log) => RequestLogTile(
                log: log,
                ignoredBasePath: _controller.ignoredBasePath,
              ),
            ),
          ).toList(),
        );
      },
    );
  }
}

class _EmptyPlaceholder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'No requests yet',
        style: DebugPageTypography.medium,
      ),
    );
  }
}
