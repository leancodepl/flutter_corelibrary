import 'dart:convert';

import 'package:debug_page/src/request_log.dart';
import 'package:debug_page/src/ui/details_screen/map_view.dart';
import 'package:debug_page/src/ui/details_screen/typography.dart';
import 'package:flutter/material.dart';

class ResponseTab extends StatelessWidget {
  const ResponseTab({
    super.key,
    required this.requestLog,
  });

  final RequestLog requestLog;

  String _prettifyJson(String json) {
    const encoder = JsonEncoder.withIndent('    ');
    return encoder.convert(jsonDecode(json));
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
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
          Text(utf8.decode(requestLog.responseBodyBytes)),
          // FutureBuilder(
          //   future: requestLog.responseBody,
          //   builder: (context, snapshot) {
          //     final body = snapshot.data;

          //     if (body == null || body.isEmpty) {
          //       return const Text('Empty body');
          //     }

          //     if (requestLog.isResponseJson) {
          //       return Text(_prettifyJson(body));
          //     }

          //     return Text(body);
          //   },
          // ),
        ],
      ),
    );
  }
}
