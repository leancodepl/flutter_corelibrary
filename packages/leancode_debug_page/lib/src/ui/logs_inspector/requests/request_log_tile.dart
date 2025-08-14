import 'package:flutter/material.dart';
import 'package:leancode_debug_page/src/models/request_log_record.dart';
import 'package:leancode_debug_page/src/ui/logs_inspector/requests/request_details_screen/request_details_screen.dart';
import 'package:leancode_debug_page/src/ui/typography.dart';

extension _ColorExtension on RequestStatus {
  Color color(BuildContext context) => switch (Theme.of(context).brightness) {
        Brightness.dark => switch (this) {
            RequestStatus.success => Colors.green.shade800,
            RequestStatus.redirect => Colors.orange.shade800,
            RequestStatus.clientError => Colors.red,
            RequestStatus.serverError => Colors.red.shade800,
            RequestStatus.unknown => Colors.grey.shade700,
          },
        Brightness.light => switch (this) {
            RequestStatus.success => Colors.green,
            RequestStatus.redirect => Colors.orange,
            RequestStatus.clientError => Colors.red.shade400,
            RequestStatus.serverError => Colors.red,
            RequestStatus.unknown => Colors.grey,
          },
      };
}

class RequestLogTile extends StatelessWidget {
  const RequestLogTile({
    super.key,
    required this.log,
    required this.ignoredBasePath,
  });

  final RequestLogRecord log;
  final String? ignoredBasePath;

  String _formatTime(DateTime time) =>
      '${time.hour}:${time.minute}:${time.second}.${time.millisecond}';

  @override
  Widget build(BuildContext context) {
    var url = log.url.toString();
    final ignoredBasePath = this.ignoredBasePath;

    if (ignoredBasePath != null && url.startsWith(ignoredBasePath)) {
      url = url.substring(ignoredBasePath.length);
    }

    return Material(
      color: log.status.color(context),
      child: ListTile(
        trailing: Text(
          log.statusCode.toString(),
          style: DebugPageTypography.small,
        ),
        onTap: () => Navigator.of(context).push(RequestDetailsRoute(log)),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(url, style: DebugPageTypography.medium),
            Text(
              '${log.method}, ${_formatTime(log.startTime)}',
              style: DebugPageTypography.small,
            ),
          ],
        ),
      ),
    );
  }
}
