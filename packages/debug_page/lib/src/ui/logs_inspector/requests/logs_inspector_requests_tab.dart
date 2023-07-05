import 'package:debug_page/src/logging_http_client.dart';
import 'package:debug_page/src/request_log.dart';
import 'package:debug_page/src/ui/logs_inspector/requests/request_log_tile.dart';
import 'package:flutter/material.dart';

class LogsInspectorRequestsTab extends StatelessWidget {
  const LogsInspectorRequestsTab({
    super.key,
    required LoggingHttpClient loggingHttpClient,
  }) : _loggingHttpClient = loggingHttpClient;

  final LoggingHttpClient _loggingHttpClient;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<RequestLog>>(
      initialData: _loggingHttpClient.logs,
      stream: _loggingHttpClient.logStream,
      builder: (context, snapshot) {
        final logs = snapshot.data;

        if (logs == null || logs.isEmpty) {
          return const Center(child: Text('No requests yet'));
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
