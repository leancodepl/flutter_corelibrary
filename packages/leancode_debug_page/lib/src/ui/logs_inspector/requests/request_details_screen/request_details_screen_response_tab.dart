import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:leancode_debug_page/src/models/request_log_record.dart';
import 'package:leancode_debug_page/src/ui/logs_inspector/map_view.dart';
import 'package:leancode_debug_page/src/ui/typography.dart';

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
              future: requestLog.responseBodyCompleter.future,
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
