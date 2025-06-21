import 'dart:async';

import 'package:http/http.dart' as http;
import 'package:leancode_debug_page/src/models/log_gatherer.dart';
import 'package:leancode_debug_page/src/models/request_log_record.dart';
import 'package:rxdart/rxdart.dart';

class LoggingHttpClient extends http.BaseClient
    implements LogGatherer<RequestLogRecord> {
  LoggingHttpClient({http.Client? client})
      : _httpClient = client ?? http.Client(),
        _logsController = BehaviorSubject.seeded([]);

  final http.Client _httpClient;
  final BehaviorSubject<List<RequestLogRecord>> _logsController;

  @override
  Stream<List<RequestLogRecord>> get logStream => _logsController.stream;
  @override
  List<RequestLogRecord> get logs => _logsController.value;

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

    final responseBodyBytes = <int>[];
    final responseBodyCompleter = Completer<String>();

    _logsController.add(
      logs
        ..add(
          RequestLogRecord(
            method: request.method,
            url: request.url,
            startTime: startTime,
            endTime: endTime,
            statusCode: response.statusCode,
            requestHeaders: request.headers,
            requestBody: requestBody,
            responseBodyCompleter: responseBodyCompleter,
            responseHeaders: response.headers,
          ),
        ),
    );

    return http.StreamedResponse(
      response.stream.doOnData(responseBodyBytes.addAll).doOnDone(() {
        responseBodyCompleter.complete(
          http.Response.bytes(responseBodyBytes, response.statusCode).body,
        );
      }),
      response.statusCode,
      contentLength: response.contentLength,
      request: response.request,
      headers: response.headers,
      isRedirect: response.isRedirect,
      persistentConnection: response.persistentConnection,
      reasonPhrase: response.reasonPhrase,
    );
  }
}
