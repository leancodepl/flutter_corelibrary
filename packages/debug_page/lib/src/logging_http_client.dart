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

    final s = StreamController<List<int>>();
    final s2 = StreamController<List<int>>();

    StreamSubscription<List<int>>? subscription;
    subscription = response.stream.listen(
      (value) {
        s.add(value);
        s2.add(value);
      },
      onDone: () {
        s.close();
        s2.close();
        subscription?.cancel();
      },
    );

    final body = http.Response.fromStream(
      http.StreamedResponse(
        s2.stream,
        response.statusCode,
      ),
    ).then((response) => response.body);

    final String requestBody;

    if (request is http.Request) {
      requestBody = request.body;
    } else {
      // TODO: Implement
      requestBody = 'Multipart request';
    }

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
            responseBody: body,
            responseHeaders: response.headers,
          ),
        ),
    );

    return http.StreamedResponse(
      s.stream,
      response.statusCode,
    );
  }
}
