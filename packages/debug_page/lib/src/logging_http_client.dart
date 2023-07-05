import 'dart:async';

import 'package:debug_page/src/models/request_log_record.dart';
import 'package:debug_page/src/models/requests_log.dart';
import 'package:http/http.dart' as http;
import 'package:rxdart/rxdart.dart';

class LoggingHttpClient extends http.BaseClient {
  LoggingHttpClient({http.Client? client})
      : _httpClient = client ?? http.Client(),
        _logs = [],
        _logsController = StreamController.broadcast();

  final http.Client _httpClient;
  final List<RequestLogRecord> _logs;
  final StreamController<RequestsLog> _logsController;

  Stream<RequestsLog> get logStream => _logsController.stream;
  List<RequestLogRecord> get logs => List.unmodifiable(_logs);

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
      RequestsLog(
        logs: _logs
          ..add(
            RequestLogRecord(
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
