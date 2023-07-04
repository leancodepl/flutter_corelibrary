import 'dart:async';

import 'package:debug_page/src/request_log.dart';
import 'package:http/http.dart' as http;
import 'package:rxdart/rxdart.dart';

class LoggingHttpClient extends http.BaseClient {
  LoggingHttpClient({http.Client? client})
      : _httpClient = client ?? http.Client(),
        _logs = [],
        _logsController = StreamController.broadcast();

  final http.Client _httpClient;
  final List<RequestLog> _logs;
  final StreamController<List<RequestLog>> _logsController;

  Stream<List<RequestLog>> get logStream => _logsController.stream;
  List<RequestLog> get logs => List.unmodifiable(_logs);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    final startTime = DateTime.now();
    final response = await _httpClient.send(request);
    final endTime = DateTime.now();

    final String? requestBody;

    if (request is http.Request) {
      requestBody = request.body;
    } else {
      requestBody = null;
    }

    var responseBodyBytes = <int>[];
    final responseBodyCompleter = Completer<String>();

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
            responseBody: responseBodyCompleter.future,
            responseHeaders: response.headers,
          ),
        ),
    );

    return http.StreamedResponse(
      response.stream.doOnData((event) {
        responseBodyBytes = event;
      }).doOnDone(() {
        responseBodyCompleter.complete(
          http.Response.bytes(responseBodyBytes, response.statusCode).body,
        );
      }),
      response.statusCode,
    );
  }
}
