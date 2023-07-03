import 'package:http/http.dart' as http;

enum StatusType {
  success,
  redirect,
  error,
  unknown;
}

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

  StatusType get statusType {
    return switch (statusCode) {
      (final code) when 200 <= code && code < 300 => StatusType.success,
      (final code) when 300 <= code && code < 400 => StatusType.redirect,
      (final code) when 400 <= code && code < 600 => StatusType.error,
      _ => StatusType.unknown
    };
  }
}
