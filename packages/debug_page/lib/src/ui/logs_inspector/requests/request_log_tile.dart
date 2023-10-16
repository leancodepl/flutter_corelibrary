import 'package:debug_page/src/models/request_log_record.dart';
import 'package:debug_page/src/ui/logs_inspector/requests/request_details_screen/request_details_screen.dart';
import 'package:debug_page/src/ui/typography.dart';
import 'package:flutter/material.dart';

extension _ColorExtension on RequestStatus {
  Color get color {
    return switch (this) {
      RequestStatus.success => Colors.green,
      RequestStatus.redirect => Colors.orange,
      RequestStatus.clientError => Colors.red.shade400,
      RequestStatus.serverError => Colors.red,
      RequestStatus.unknown => Colors.grey,
    };
  }
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

    return ListTile(
      trailing: Text(
        log.statusCode.toString(),
        style: DebugPageTypography.small,
      ),
      tileColor: log.status.color,
      onTap: () => Navigator.of(context).push(RequestDetailsRoute(log)),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(url, style: DebugPageTypography.medium),
          Row(
            children: [
              Text(
                '${log.method}, ${_formatTime(log.startTime)}',
                style: DebugPageTypography.small,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
