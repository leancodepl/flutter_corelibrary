import 'package:debug_page/src/logging_http_client.dart';
import 'package:debug_page/src/models/request_log.dart';
import 'package:debug_page/src/ui/logs_inspector/requests/requests_tab_filters_menu.dart';
import 'package:debug_page/src/ui/logs_inspector/requests/request_log_tile.dart';
import 'package:debug_page/src/ui/typography.dart';
import 'package:flutter/material.dart';

class LogsInspectorRequestsTab extends StatelessWidget {
  const LogsInspectorRequestsTab({
    super.key,
    required LoggingHttpClient loggingHttpClient,
    required this.showFilters,
  }) : _loggingHttpClient = loggingHttpClient;

  final LoggingHttpClient _loggingHttpClient;
  final bool showFilters;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (showFilters) const RequestsTabFiltersMenu(),
        Expanded(
          child: _LogsInspectorRequestsTabContent(
            loggingHttpClient: _loggingHttpClient,
          ),
        ),
      ],
    );
  }
}

class _LogsInspectorRequestsTabContent extends StatelessWidget {
  const _LogsInspectorRequestsTabContent({
    required LoggingHttpClient loggingHttpClient,
  }) : _loggingHttpClient = loggingHttpClient;

  final LoggingHttpClient _loggingHttpClient;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<RequestLogRecord>>(
      initialData: _loggingHttpClient.logs,
      stream: _loggingHttpClient.logStream,
      builder: (context, snapshot) {
        final logs = snapshot.data;

        if (logs == null || logs.isEmpty) {
          return Center(
            child: Text(
              'No requests yet',
              style: DebugPageTypography.medium,
            ),
          );
        }

        return ListView(
          children: ListTile.divideTiles(
            context: context,
            tiles: logs.reversed.map(
              (log) => RequestLogTile(log: log),
            ),
          ).toList(),
        );
      },
    );
  }
}
