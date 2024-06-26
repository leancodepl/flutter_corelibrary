import 'package:http/http.dart' as http;

// Based on https://stackoverflow.com/a/51106300
http.BaseRequest copyRequest(http.BaseRequest request) {
  http.BaseRequest requestCopy;

  if (request is http.Request) {
    requestCopy = http.Request(request.method, request.url)
      ..encoding = request.encoding
      ..bodyBytes = request.bodyBytes;
  } else if (request is http.MultipartRequest) {
    requestCopy = http.MultipartRequest(request.method, request.url)
      ..fields.addAll(request.fields)
      ..files.addAll(request.files);
  } else if (request is http.StreamedRequest) {
    throw Exception('copying streamed requests is not supported');
  } else {
    throw Exception('request type is unknown, cannot copy');
  }

  requestCopy
    ..persistentConnection = request.persistentConnection
    ..followRedirects = request.followRedirects
    ..maxRedirects = request.maxRedirects
    ..headers.addAll(request.headers);

  return requestCopy;
}
