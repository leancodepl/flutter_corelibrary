import 'package:debug_page/src/core/debug_page_controller.dart';
import 'package:debug_page/src/models/filter.dart';
import 'package:debug_page/src/ui/logs_inspector/logger/logger_log_tile.dart';
import 'package:debug_page/src/ui/logs_inspector/logger/logger_tab_filters_menu.dart';
import 'package:debug_page/src/ui/typography.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';

class LogsInspectorLoggerTab extends StatefulWidget {
  const LogsInspectorLoggerTab({
    super.key,
    required DebugPageController controller,
    required bool showFilters,
  })  : _controller = controller,
        _showFilters = showFilters;

  final DebugPageController _controller;
  final bool _showFilters;

  @override
  State<StatefulWidget> createState() {
    return _LogsInspectorLoggerTabState();
  }
}

class _LogsInspectorLoggerTabState extends State<LogsInspectorLoggerTab> {
  final _filters = ValueNotifier<List<Filter<LogRecord>>>([]);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (widget._showFilters)
          LoggerTabFiltersMenu(
            onFiltersChanged: (value) => _filters.value = value,
          ),
        Expanded(
          child: ValueListenableBuilder(
            valueListenable: _filters,
            builder: (context, filters, child) =>
                _LogsInspectorLoggerTabContent(
              controller: widget._controller,
              filters: filters,
            ),
          ),
        ),
      ],
    );
  }
}

class _LogsInspectorLoggerTabContent extends StatelessWidget {
  const _LogsInspectorLoggerTabContent({
    required DebugPageController controller,
    required List<Filter<LogRecord>> filters,
  })  : _controller = controller,
        _filters = filters;

  final DebugPageController _controller;
  final List<Filter<LogRecord>> _filters;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<LogRecord>>(
      initialData: _controller.loggerLogs,
      stream: _controller.loggerLogStream,
      builder: (context, snapshot) {
        final logs = snapshot.data;

        if (logs == null) {
          return const _EmptyPlaceholder();
        }

        final filterLogs = _filters.apply(logs);

        return FutureBuilder(
          future: filterLogs,
          builder: (context, snapshot) {
            final filteredLogs = snapshot.data;

            if (filteredLogs == null) {
              return const CircularProgressIndicator();
            }

            if (filteredLogs.isEmpty) {
              return const _EmptyPlaceholder();
            }

            return ListView(
              children: ListTile.divideTiles(
                context: context,
                tiles:
                    filteredLogs.reversed.map((log) => LoggerLogTile(log: log)),
              ).toList(),
            );
          },
        );
      },
    );
  }
}

class _EmptyPlaceholder extends StatelessWidget {
  const _EmptyPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'No logs yet',
        style: DebugPageTypography.medium,
      ),
    );
  }
}
