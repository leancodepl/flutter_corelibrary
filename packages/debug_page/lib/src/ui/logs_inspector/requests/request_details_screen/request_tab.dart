import 'package:debug_page/src/models/request_log_record.dart';
import 'package:debug_page/src/ui/logs_inspector/map_view.dart';
import 'package:debug_page/src/ui/typography.dart';
import 'package:flutter/material.dart';

class RequestDetailsScreenRequestTab extends StatelessWidget {
  const RequestDetailsScreenRequestTab({
    super.key,
    required this.requestLog,
  });

  final RequestLogRecord requestLog;

  @override
  Widget build(BuildContext context) {
    final headers = requestLog.requestHeaders;
    final body = requestLog.requestBody;

    return SingleChildScrollView(
      child: DefaultTextStyle(
        style: DebugPageTypography.medium,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Headers', style: DebugPageTypography.large),
            const SizedBox(height: 8),
            if (headers.isNotEmpty)
              MapView(map: requestLog.requestHeaders)
            else
              const Text('Empty headers'),
            const SizedBox(height: 16),
            Text(
              'Body',
              style: DebugPageTypography.large,
            ),
            const SizedBox(height: 8),
            if (body != null && body.isNotEmpty)
              Text(body)
            else
              const Text('Body either empty or not logged due to request type'),
          ],
        ),
      ),
    );
  }
}
