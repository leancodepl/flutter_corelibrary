import 'package:debug_page/src/logging_http_client.dart';
import 'package:debug_page/src/models/requests_log.dart';
import 'package:debug_page/src/ui/logs_inspector/requests/requests_tab_filters_menu.dart';
import 'package:debug_page/src/ui/logs_inspector/requests/request_log_tile.dart';
import 'package:debug_page/src/ui/typography.dart';
import 'package:flutter/material.dart';

class LogsInspectorRequestsTab extends StatefulWidget {
  const LogsInspectorRequestsTab({
    super.key,
    required LoggingHttpClient loggingHttpClient,
    required this.showFilters,
  }) : _loggingHttpClient = loggingHttpClient;

  final LoggingHttpClient _loggingHttpClient;
  final bool showFilters;

  @override
  State<LogsInspectorRequestsTab> createState() =>
      _LogsInspectorRequestsTabState();
}

class _LogsInspectorRequestsTabState extends State<LogsInspectorRequestsTab> {
  final _filters = ValueNotifier<List<IRequestFilter>>([]);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (widget.showFilters)
          RequestsTabFiltersMenu(
            onFiltersChanged: (value) {
              _filters.value = value;
            },
          ),
        Expanded(
          child: ValueListenableBuilder(
            valueListenable: _filters,
            builder: (context, filters, child) =>
                _LogsInspectorRequestsTabContent(
              loggingHttpClient: widget._loggingHttpClient,
              filters: filters,
            ),
          ),
        ),
      ],
    );
  }
}

class _LogsInspectorRequestsTabContent extends StatelessWidget {
  const _LogsInspectorRequestsTabContent({
    required LoggingHttpClient loggingHttpClient,
    required this.filters,
  }) : _loggingHttpClient = loggingHttpClient;

  final LoggingHttpClient _loggingHttpClient;
  final List<IRequestFilter> filters;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<RequestsLog>(
      initialData: RequestsLog(logs: _loggingHttpClient.logs),
      stream: _loggingHttpClient.logStream,
      builder: (context, snapshot) {
        final requestsLog = snapshot.data;
        final filteredLogs = requestsLog?.getFilteredLogs(filters: filters);

        if (filteredLogs == null || filteredLogs.isEmpty) {
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
            tiles: filteredLogs.reversed.map(
              (log) => RequestLogTile(log: log),
            ),
          ).toList(),
        );
      },
    );
  }
}
