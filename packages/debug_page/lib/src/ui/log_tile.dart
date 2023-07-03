import 'package:debug_page/src/request_log.dart';
import 'package:debug_page/src/ui/details_screen/details_screen.dart';
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

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(log.url.toString()),
      trailing: Text(log.statusCode.toString()),
      tileColor: log.statusType.color,
      onTap: () => Navigator.of(context).push(DetailsRoute(log)),
    );
  }
}
