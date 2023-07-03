import 'package:debug_page/src/request_log.dart';
import 'package:http/http.dart' as http;

class LoggingHttpClient extends http.BaseClient {
  LoggingHttpClient({http.Client? client})
      : _httpClient = client ?? http.Client(),
        _logs = [];

  final http.Client _httpClient;
  final List<RequestLog> _logs;
  Iterable<RequestLog> get logs => List.unmodifiable(_logs);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    final response = await _httpClient.send(request);

    _logs.add(
      RequestLog(
        url: request.url,
        statusCode: response.statusCode,
        requestHeaders: request.headers,
        response: response,
        responseHeaders: response.headers,
      ),
    );

    return response;
  }
}
