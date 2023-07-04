import 'package:debug_page/src/request_log.dart';
import 'package:debug_page/src/ui/details_screen/map_view.dart';
import 'package:flutter/material.dart';

class OverviewTab extends StatelessWidget {
  const OverviewTab({
    super.key,
    required this.requestLog,
  });

  final RequestLog requestLog;

  @override
  Widget build(BuildContext context) {
    return MapView(
      map: {
        'Method': requestLog.method,
        'Host': requestLog.url.host,
        'Endpoint': requestLog.url.path,
        'Status code': requestLog.statusCode,
        'Start time': requestLog.startTime,
        'End time': requestLog.endTime,
        'Duration': requestLog.duration,
      },
    );
  }
}
