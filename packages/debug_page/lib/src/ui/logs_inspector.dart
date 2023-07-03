import 'package:debug_page/debug_page.dart';
import 'package:debug_page/src/request_log.dart';
import 'package:debug_page/src/ui/log_tile.dart';
import 'package:flutter/material.dart';

class LogsInspector extends StatelessWidget {
  const LogsInspector({
    super.key,
    required LoggingHttpClient loggingHttpClient,
  }) : _loggingHttpClient = loggingHttpClient;

  final LoggingHttpClient _loggingHttpClient;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<RequestLog>>(
      stream: _loggingHttpClient.logs,
      builder: (context, snapshot) {
        final logs = snapshot.data;

        if (logs == null) {
          // TODO: Return empty list placeholder
          return const SizedBox();
        }

        return ListView(
          children: ListTile.divideTiles(
            context: context,
            tiles: logs.reversed.map(
              (log) => LogTile(log: log),
            ),
          ).toList(),
        );
      },
    );
  }
}
