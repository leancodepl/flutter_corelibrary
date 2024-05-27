import 'package:flutter/material.dart';
import 'package:leancode_debug_page/src/models/request_log_record.dart';
import 'package:leancode_debug_page/src/ui/logs_inspector/map_view.dart';

class RequestDetailsScreenOverviewTab extends StatelessWidget {
  const RequestDetailsScreenOverviewTab({
    super.key,
    required this.requestLog,
  });

  final RequestLogRecord requestLog;

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
