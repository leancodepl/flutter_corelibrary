import 'package:debug_page/src/core/logging_http_client.dart';
import 'package:debug_page/src/models/filter.dart';
import 'package:debug_page/src/models/request_log_record.dart';
import 'package:debug_page/src/models/requests_log.dart';
import 'package:debug_page/src/ui/logs_inspector/requests/requests_tab_filters_menu.dart';
import 'package:debug_page/src/ui/logs_inspector/requests/request_log_tile.dart';
import 'package:debug_page/src/ui/typography.dart';
import 'package:flutter/material.dart';

class LogsInspectorRequestsTab extends StatefulWidget {
  const LogsInspectorRequestsTab({
    super.key,
    required LoggingHttpClient loggingHttpClient,
    required bool showFilters,
  })  : _loggingHttpClient = loggingHttpClient,
        _showFilters = showFilters;

  final LoggingHttpClient _loggingHttpClient;
  final bool _showFilters;

  @override
  State<LogsInspectorRequestsTab> createState() =>
      _LogsInspectorRequestsTabState();
}

class _LogsInspectorRequestsTabState extends State<LogsInspectorRequestsTab> {
  final _filters = ValueNotifier<List<Filter<RequestLogRecord>>>([]);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (widget._showFilters)
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
    required List<Filter<RequestLogRecord>> filters,
  })  : _loggingHttpClient = loggingHttpClient,
        _filters = filters;

  final LoggingHttpClient _loggingHttpClient;
  final List<Filter<RequestLogRecord>> _filters;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<RequestsLog>(
      initialData: RequestsLog(logs: _loggingHttpClient.logs),
      stream: _loggingHttpClient.logStream,
      builder: (context, snapshot) {
        final requestsLog = snapshot.data;

        if (requestsLog == null) {
          return _EmptyPlaceholder();
        }

        final filteredLogs = _filters.apply(requestsLog.logs);

        if (filteredLogs.isEmpty) {
          return _EmptyPlaceholder();
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
