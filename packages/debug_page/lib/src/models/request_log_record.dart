enum RequestStatus {
  success,
  redirect,
  clientError,
  serverError,
  unknown;
}

class RequestLogRecord {
  const RequestLogRecord({
    required this.method,
    required this.url,
    required this.startTime,
    required this.endTime,
    required this.statusCode,
    required this.requestHeaders,
    required this.requestBody,
    required this.responseHeaders,
    required this.responseBody,
  });

  final String method;
  final Uri url;
  final DateTime startTime;
  final DateTime endTime;
  final int statusCode;
  final Map<String, String> requestHeaders;
  final String? requestBody;
  final Map<String, String> responseHeaders;
  final Future<String> responseBody;

  Duration get duration => endTime.difference(startTime);

  bool get isResponseJson {
    if (responseHeaders['content-type']?.contains('application/json') ??
        false) {
      return true;
    }

    return false;
  }

  RequestStatus get status {
    return switch (statusCode) {
      (final code) when 200 <= code && code < 300 => RequestStatus.success,
      (final code) when 300 <= code && code < 400 => RequestStatus.redirect,
      (final code) when 400 <= code && code < 500 => RequestStatus.clientError,
      (final code) when 500 <= code && code < 600 => RequestStatus.clientError,
      _ => RequestStatus.unknown
    };
  }

  Future<String> toSummary(bool includeResponse) async {
    final buffer = StringBuffer()
      ..writeln('HTTP Request')
      ..writeln('Method: $method')
      ..writeln('Url: $url')
      ..writeln('Status code: $statusCode')
      ..writeln('Start time: $startTime')
      ..writeln('End time: $endTime')
      ..writeln('Request headers: $requestHeaders')
      ..writeln('Request body: $requestBody')
      ..writeln('Response headers: $responseHeaders');

    if (includeResponse) {
      final responseBody = await this.responseBody;
      buffer.writeln('Respones body: $responseBody');
    }

    return buffer.toString();
  }
}
