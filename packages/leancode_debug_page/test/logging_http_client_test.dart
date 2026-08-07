// The arguments provided in this file are explicitly included for clarity in tests,
// even though they may be redundant. This improves readability and ensures the test cases
// clearly show all parameters being tested.
// ignore_for_file: avoid_redundant_argument_values

import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart';
import 'package:leancode_debug_page/src/core/logging_http_client.dart';
import 'package:leancode_debug_page/src/models/request_log_record.dart';
import 'package:mocktail/mocktail.dart';

import 'util/mock_http_client.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('LoggingHttpClient', () {
    final homeUrl = Uri.parse('https://leancode.co/');
    final request = Request('get', homeUrl);
    const stream = Stream<List<int>>.empty();
    const statusCode = 200;
    const contentLength = 123;
    const headers = <String, String>{};
    const isRedirect = false;
    const persistentConnection = true;
    const reasonPhrase = 'reasonPhrase';

    late MockHttpClient mockHttpClient;
    late LoggingHttpClient loggingHttpClient;

    setUpAll(() {
      registerFallbackValue(Request('get', Uri()));
    });

    setUp(() {
      mockHttpClient = MockHttpClient();
      loggingHttpClient = LoggingHttpClient(client: mockHttpClient);

      when<Future<StreamedResponse>>(
        () => mockHttpClient.send(any()),
      ).thenAnswer(
        (invocation) async => StreamedResponse(
          stream,
          statusCode,
          contentLength: contentLength,
          request: request,
          headers: headers,
          isRedirect: isRedirect,
          persistentConnection: persistentConnection,
          reasonPhrase: reasonPhrase,
        ),
      );
    });

    test(
      'send a http request through logging http client and log it',
      () async {
        await loggingHttpClient.get(homeUrl);

        await expectLater(
          loggingHttpClient.logStream,
          emits(const TypeMatcher<List<RequestLogRecord>>()),
        );
      },
    );

    test('rewrites all response fields', () async {
      final response = await loggingHttpClient.send(request);

      expect(response.stream, isA<Stream<dynamic>>());
      expect(response.statusCode, statusCode);
      expect(response.contentLength, contentLength);
      expect(response.request, request);
      expect(response.headers, headers);
      expect(response.isRedirect, isRedirect);
      expect(response.persistentConnection, persistentConnection);
      expect(response.reasonPhrase, reasonPhrase);
    });

    test('decodes request body using request encoding', () async {
      final request = Request('post', homeUrl)
        ..encoding = latin1
        ..bodyBytes = [0xE9];

      when<Future<StreamedResponse>>(
        () => mockHttpClient.send(any()),
      ).thenAnswer(
        (invocation) async => StreamedResponse(
          stream,
          statusCode,
          contentLength: contentLength,
          request: request,
          headers: headers,
          isRedirect: isRedirect,
          persistentConnection: persistentConnection,
          reasonPhrase: reasonPhrase,
        ),
      );

      await loggingHttpClient.send(request);

      expect(loggingHttpClient.logs.single.requestBody, 'é');
    });

    test('logs binary request body when decoding fails', () async {
      final request = Request('post', homeUrl)..bodyBytes = [0xBE, 0xEF, 0x00];

      when<Future<StreamedResponse>>(
        () => mockHttpClient.send(any()),
      ).thenAnswer(
        (invocation) async => StreamedResponse(
          stream,
          statusCode,
          contentLength: contentLength,
          request: request,
          headers: headers,
          isRedirect: isRedirect,
          persistentConnection: persistentConnection,
          reasonPhrase: reasonPhrase,
        ),
      );

      await loggingHttpClient.send(request);

      expect(
        loggingHttpClient.logs.single.requestBody,
        '[binary body, 3 bytes]',
      );
    });

    test(
      'logs binary request body when explicit encoding cannot decode body',
      () async {
        final request = Request('post', homeUrl)
          ..encoding = utf8
          ..bodyBytes = [0xBE, 0xEF];

        when<Future<StreamedResponse>>(
          () => mockHttpClient.send(any()),
        ).thenAnswer(
          (invocation) async => StreamedResponse(
            stream,
            statusCode,
            contentLength: contentLength,
            request: request,
            headers: headers,
            isRedirect: isRedirect,
            persistentConnection: persistentConnection,
            reasonPhrase: reasonPhrase,
          ),
        );

        await loggingHttpClient.send(request);

        expect(
          loggingHttpClient.logs.single.requestBody,
          '[binary body, 2 bytes]',
        );
      },
    );

    Future<String> logResponseBody(
      List<int> responseBodyBytes, {
      Map<String, String> responseHeaders = const {},
    }) async {
      when<Future<StreamedResponse>>(
        () => mockHttpClient.send(any()),
      ).thenAnswer(
        (invocation) async => StreamedResponse(
          Stream.value(responseBodyBytes),
          statusCode,
          contentLength: responseBodyBytes.length,
          request: request,
          headers: responseHeaders,
          isRedirect: isRedirect,
          persistentConnection: persistentConnection,
          reasonPhrase: reasonPhrase,
        ),
      );

      final response = await loggingHttpClient.send(request);
      await response.stream.drain<void>();

      return loggingHttpClient.logs.single.responseBodyCompleter.future;
    }

    test('decodes a charset-less json response body as utf8', () async {
      expect(
        await logResponseBody(
          utf8.encode('Łódź'),
          responseHeaders: {'content-type': 'application/json'},
        ),
        'Łódź',
      );
    });

    test('decodes response body using the declared charset', () async {
      expect(
        await logResponseBody(
          utf8.encode('Łódź'),
          responseHeaders: {'content-type': 'text/plain; charset=utf-8'},
        ),
        'Łódź',
      );
    });

    test('honours a declared charset other than utf8', () async {
      expect(
        await logResponseBody(
          latin1.encode('Éé'),
          responseHeaders: {'content-type': 'text/plain; charset="iso-8859-1"'},
        ),
        'Éé',
      );
    });

    // Only `application/json` gets utf8 out of `http` without a charset; every
    // other type falls back to latin1. Pinned so widening it is a deliberate
    // change rather than a surprise.
    test('leaves a charset-less text response on latin1', () async {
      expect(
        await logResponseBody(
          utf8.encode('Łódź'),
          responseHeaders: {'content-type': 'text/plain'},
        ),
        latin1.decode(utf8.encode('Łódź')),
      );
    });

    test('logs binary response body when decoding fails', () async {
      expect(
        await logResponseBody(
          [0xBE, 0xEF],
          responseHeaders: {'content-type': 'application/json'},
        ),
        '[binary body, 2 bytes]',
      );
    });

    test('logs binary response body for an unparseable content type', () async {
      expect(
        await logResponseBody(
          utf8.encode('Łódź'),
          responseHeaders: {'content-type': 'not a media type'},
        ),
        '[binary body, 7 bytes]',
      );
    });

    test('clear logs', () async {
      await loggingHttpClient.get(homeUrl);
      expect(loggingHttpClient.logs, hasLength(1));

      loggingHttpClient.clear();

      expect(loggingHttpClient.logs, isEmpty);
      await expectLater(loggingHttpClient.logStream, emits(isEmpty));
    });
  });
}
