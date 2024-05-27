import 'package:debug_page/src/core/debug_page_controller.dart';
import 'package:debug_page/src/ui/logs_inspector/logger/logger_log_tile.dart';
import 'package:debug_page/src/ui/logs_inspector/logger/logger_tab_filters_menu.dart';
import 'package:debug_page/src/ui/typography.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';

class LogsInspectorLoggerTab extends StatelessWidget {
  const LogsInspectorLoggerTab({
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
        if (_showFilters) LoggerTabFiltersMenu(controller: _controller),
        Expanded(
          child: _LogsInspectorLoggerTabContent(controller: _controller),
        ),
      ],
    );
  }
}

class _LogsInspectorLoggerTabContent extends StatelessWidget {
  const _LogsInspectorLoggerTabContent({
    required DebugPageController controller,
  }) : _controller = controller;

  final DebugPageController _controller;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<LogRecord>>(
      initialData: _controller.loggerLogs,
      stream: _controller.loggerLogStream,
      builder: (context, snapshot) {
        final logs = snapshot.data;

        if (logs == null || logs.isEmpty) {
          return const _EmptyPlaceholder();
        }

        return ListView(
          children: ListTile.divideTiles(
            context: context,
            tiles: logs.reversed.map((log) => LoggerLogTile(log: log)),
          ).toList(),
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
