import 'package:debug_page/src/logger_listener.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';

extension ColorExtension on Level {
  Color get color {
    return switch (this) {
      Level.FINE || Level.FINER || Level.FINEST => Colors.green,
      Level.CONFIG || Level.INFO => Colors.lightGreen,
      Level.WARNING => Colors.orange,
      Level.SEVERE => Colors.red,
      _ => Colors.grey,
    };
  }
}

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
          return const Text('Empty');
        }

        return ListView(
          children: ListTile.divideTiles(
            context: context,
            tiles: logs.reversed.map(
              (log) => ListTile(
                title: Text(log.message),
                tileColor: log.level.color,
              ),
            ),
          ).toList(),
        );
      },
    );
  }
}
