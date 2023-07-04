import 'package:debug_page/src/logger_listener.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';

class LogsInspectorLoggerTab extends StatelessWidget {
  const LogsInspectorLoggerTab(
      {super.key, required LoggerListener loggerListener})
      : _loggerListener = loggerListener;

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
          children: logs
              .map(
                (log) => ListTile(title: Text(log.message)),
              )
              .toList(),
        );
      },
    );
  }
}
