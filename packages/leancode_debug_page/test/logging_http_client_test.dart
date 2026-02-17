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

  group(
    'LoggingHttpClient',
    () {
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

        when<Future<StreamedResponse>>(() => mockHttpClient.send(any()))
            .thenAnswer(
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

      test(
        'rewrites all response fields',
        () async {
          final response = await loggingHttpClient.send(request);

          expect(response.stream, isA<Stream<dynamic>>());
          expect(response.statusCode, statusCode);
          expect(response.contentLength, contentLength);
          expect(response.request, request);
          expect(response.headers, headers);
          expect(response.isRedirect, isRedirect);
          expect(response.persistentConnection, persistentConnection);
          expect(response.reasonPhrase, reasonPhrase);
        },
      );

      test(
        'clear logs',
        () async {
          await loggingHttpClient.get(homeUrl);
          expect(loggingHttpClient.logs, hasLength(1));

          loggingHttpClient.clear();

          expect(loggingHttpClient.logs, isEmpty);
          await expectLater(
            loggingHttpClient.logStream,
            emits(isEmpty),
          );
        },
      );

      test(
        'properly decodes UTF-8 characters including Polish letters',
        () async {
          const polishText = 'Autoryzacja nie została wykonana. Łódź, Gdańsk, Kraków.';
          final polishBytes = utf8.encode(polishText);
          final streamWithPolishText = Stream.fromIterable([polishBytes]);

          when<Future<StreamedResponse>>(() => mockHttpClient.send(any()))
              .thenAnswer(
            (invocation) async => StreamedResponse(
              streamWithPolishText,
              statusCode,
              contentLength: polishBytes.length,
              request: request,
              headers: headers,
              isRedirect: isRedirect,
              persistentConnection: persistentConnection,
              reasonPhrase: reasonPhrase,
            ),
          );

          await loggingHttpClient.send(request);

          // Wait for the response body to be completed
          await Future.delayed(const Duration(milliseconds: 100));

          expect(loggingHttpClient.logs, hasLength(1));
          final log = loggingHttpClient.logs.first;
          final responseBody = await log.responseBodyCompleter.future;

          expect(responseBody, contains('Autoryzacja'));
          expect(responseBody, contains('Łódź'));
          expect(responseBody, contains('Gdańsk'));
          expect(responseBody, contains('Kraków'));
        },
      );
    },
  );
}
