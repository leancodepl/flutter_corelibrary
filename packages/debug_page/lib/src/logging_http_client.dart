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

    _logsController.add(
      _logs
        ..add(
          RequestLog(
            url: request.url,
            startTime: startTime,
            endTime: endTime,
            statusCode: response.statusCode,
            requestHeaders: request.headers,
            response: response,
            responseHeaders: response.headers,
          ),
        ),
    );

    return response;
  }
}
