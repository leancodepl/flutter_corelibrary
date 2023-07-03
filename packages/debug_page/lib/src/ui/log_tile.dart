import 'package:debug_page/src/request_log.dart';
import 'package:debug_page/src/ui/details_screen/details_screen.dart';
import 'package:debug_page/src/ui/details_screen/typography.dart';
import 'package:flutter/material.dart';

extension _ColorExtension on StatusType {
  Color get color {
    return switch (this) {
      StatusType.success => Colors.green,
      StatusType.redirect => Colors.orange,
      StatusType.error => Colors.red,
      StatusType.unknown => Colors.grey,
    };
  }
}

class LogTile extends StatelessWidget {
  const LogTile({
    super.key,
    required this.log,
  });

  final RequestLog log;

  String _formatTime(DateTime time) =>
      '${time.hour}:${time.minute}:${time.second}.${time.millisecond}';

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(log.url.toString()),
          Row(
            children: [
              Text(
                '${log.method}, ${_formatTime(log.startTime)}',
                style: DebugPageTypography.small,
              ),
            ],
          )
        ],
      ),
      trailing: Text(log.statusCode.toString()),
      tileColor: log.statusType.color,
      onTap: () => Navigator.of(context).push(DetailsRoute(log)),
    );
  }
}
