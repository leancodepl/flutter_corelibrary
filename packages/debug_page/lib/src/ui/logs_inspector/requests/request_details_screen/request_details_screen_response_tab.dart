import 'dart:convert';

import 'package:debug_page/src/models/request_log.dart';
import 'package:debug_page/src/ui/logs_inspector/requests/request_details_screen/map_view.dart';
import 'package:debug_page/src/ui/typography.dart';
import 'package:flutter/material.dart';

class RequestDetailsScreenResponseTab extends StatelessWidget {
  const RequestDetailsScreenResponseTab({
    super.key,
    required this.requestLog,
  });

  final RequestLogRecord requestLog;

  String _prettifyJson(String json) {
    const encoder = JsonEncoder.withIndent('    ');
    return encoder.convert(jsonDecode(json));
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: DefaultTextStyle(
        style: DebugPageTypography.medium,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Headers', style: DebugPageTypography.large),
            const SizedBox(height: 8),
            MapView(map: requestLog.responseHeaders),
            const SizedBox(height: 16),
            Text(
              'Body',
              style: DebugPageTypography.large,
            ),
            FutureBuilder(
              future: requestLog.responseBody,
              builder: (context, snapshot) {
                final body = snapshot.data;

                if (body == null || body.isEmpty) {
                  return const Text(
                    'Body is either empty or has not been read yet.',
                  );
                }

                if (requestLog.isResponseJson) {
                  return Text(_prettifyJson(body));
                }

                return Text(body);
              },
            ),
          ],
        ),
      ),
    );
  }
}
