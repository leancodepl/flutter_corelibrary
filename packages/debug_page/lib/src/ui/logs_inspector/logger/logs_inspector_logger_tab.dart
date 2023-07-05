import 'package:debug_page/src/logger_listener.dart';
import 'package:debug_page/src/ui/logs_inspector/logger/logger_log_tile.dart';
import 'package:debug_page/src/ui/typography.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';

class LogsInspectorLoggerTab extends StatelessWidget {
  const LogsInspectorLoggerTab({
    super.key,
    required LoggerListener loggerListener,
  }) : _loggerListener = loggerListener;

  final LoggerListener _loggerListener;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<LogRecord>>(
      initialData: _loggerListener.logs,
      stream: _loggerListener.logStream,
      builder: (context, snapshot) {
        final logs = snapshot.data;

        if (logs == null || logs.isEmpty) {
          return Center(
            child: Text(
              'No logs yet',
              style: DebugPageTypography.medium,
            ),
          );
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
