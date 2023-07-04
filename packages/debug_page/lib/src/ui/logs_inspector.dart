import 'package:debug_page/debug_page.dart';
import 'package:debug_page/src/request_log.dart';
import 'package:debug_page/src/ui/details_screen/typography.dart';
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
      stream: _loggingHttpClient.logStream,
      builder: (context, snapshot) {
        final logs = snapshot.data;

        if (logs == null) {
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
            tiles: logs.reversed.map(
              (log) => LogTile(log: log),
            ),
          ).toList(),
        );
      },
    );
  }
}
