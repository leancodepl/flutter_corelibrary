enum StatusType {
  success,
  redirect,
  error,
  unknown;
}

class RequestLog {
  const RequestLog({
    required this.method,
    required this.url,
    required this.startTime,
    required this.endTime,
    required this.statusCode,
    required this.requestHeaders,
    required this.requestBody,
    required this.responseHeaders,
    required this.responseBodyBytes,
  });

  final String method;
  final Uri url;
  final DateTime startTime;
  final DateTime endTime;
  final int statusCode;
  final Map<String, String> requestHeaders;
  final String requestBody;
  final Map<String, String> responseHeaders;
  final List<int> responseBodyBytes;

  Duration get duration => endTime.difference(startTime);

  bool get isResponseJson {
    if (responseHeaders['content-type']?.contains('application/json') ??
        false) {
      return true;
    }

    return false;
  }

  StatusType get statusType {
    return switch (statusCode) {
      (final code) when 200 <= code && code < 300 => StatusType.success,
      (final code) when 300 <= code && code < 400 => StatusType.redirect,
      (final code) when 400 <= code && code < 600 => StatusType.error,
      _ => StatusType.unknown
    };
  }
}
