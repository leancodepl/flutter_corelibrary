import 'package:debug_page/src/request_log.dart';
import 'package:debug_page/src/ui/details_screen/map_view.dart';
import 'package:debug_page/src/ui/details_screen/typography.dart';
import 'package:flutter/material.dart';

class RequestTab extends StatelessWidget {
  const RequestTab({
    super.key,
    required this.requestLog,
  });

  final RequestLog requestLog;

  @override
  Widget build(BuildContext context) {
    final headers = requestLog.requestHeaders;
    final body = requestLog.requestBody;

    return SingleChildScrollView(
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
          if (body.isNotEmpty)
            Text(requestLog.requestBody)
          else
            const Text('Empty body'),
        ],
      ),
    );
  }
}
