import 'package:debug_page/src/core/debug_page_controller.dart';
import 'package:debug_page/src/models/filter.dart';
import 'package:debug_page/src/models/request_log_record.dart';
import 'package:debug_page/src/ui/logs_inspector/requests/requests_tab_filters_menu.dart';
import 'package:debug_page/src/ui/logs_inspector/requests/request_log_tile.dart';
import 'package:debug_page/src/ui/typography.dart';
import 'package:flutter/material.dart';

class LogsInspectorRequestsTab extends StatefulWidget {
  const LogsInspectorRequestsTab({
    super.key,
    required DebugPageController controller,
    required bool showFilters,
  })  : _controller = controller,
        _showFilters = showFilters;

  final DebugPageController _controller;
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
              controller: widget._controller,
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
    required DebugPageController controller,
    required List<Filter<RequestLogRecord>> filters,
  })  : _controller = controller,
        _filters = filters;

  final DebugPageController _controller;
  final List<Filter<RequestLogRecord>> _filters;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<RequestLogRecord>>(
      initialData: _controller.requestsLogs,
      stream: _controller.requestsLogStream,
      builder: (context, snapshot) {
        final logs = snapshot.data;

        if (logs == null) {
          return _EmptyPlaceholder();
        }

        final filterLogs = _filters.apply(logs);

        return FutureBuilder(
          future: filterLogs,
          builder: (context, snapshot) {
            final filteredLogs = snapshot.data;

            if (filteredLogs == null || filteredLogs.isEmpty == true) {
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
