import 'dart:async';

import 'package:debug_page/src/request_log.dart';
import 'package:http/http.dart' as http;

class LoggingHttpClient extends http.BaseClient {
  LoggingHttpClient({http.Client? client})
      : _httpClient = client ?? http.Client(),
        _logs = [],
        _logsController = StreamController.broadcast();

  final http.Client _httpClient;
  final List<RequestLog> _logs;
  final StreamController<List<RequestLog>> _logsController;

  Stream<List<RequestLog>> get logs => _logsController.stream;

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    final startTime = DateTime.now();
    final response = await _httpClient.send(request);
    final endTime = DateTime.now();

    final String requestBody;

    if (request is http.Request) {
      requestBody = request.body;
    } else {
      // TODO: Implement
      requestBody = 'Multipart request';
    }

    final bytes = <int>[];

    _logsController.add(
      _logs
        ..add(
          RequestLog(
            method: request.method,
            url: request.url,
            startTime: startTime,
            endTime: endTime,
            statusCode: response.statusCode,
            requestHeaders: request.headers,
            requestBody: requestBody,
            responseBodyBytes: bytes,
            responseHeaders: response.headers,
          ),
        ),
    );

    return http.StreamedResponse(
      response.stream.map((event) {
        bytes.addAll(event.skip(bytes.length));
        return event;
      }),
      response.statusCode,
    );
  }
}
