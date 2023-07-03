import 'package:http/http.dart' as http;

class RequestLog {
  const RequestLog({
    required this.url,
    required this.statusCode,
    required this.requestHeaders,
    required this.response,
    required this.responseHeaders,
  });

  final Uri url;
  final int statusCode;
  final Map<String, String> requestHeaders;

  final http.StreamedResponse response;
  final Map<String, String> responseHeaders;
}
