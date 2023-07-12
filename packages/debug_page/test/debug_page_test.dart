import 'dart:convert';

import 'package:debug_page/src/core/filters/request_filters.dart';
import 'package:debug_page/src/models/request_log_record.dart';
import 'package:debug_page/src/ui/logs_inspector/requests/requests_tab_filters_menu.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:debug_page/debug_page.dart';
import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';

class MockHttpClient extends Mock implements http.Client {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final leancodeWebsiteUrl = Uri.parse('https://leancode.co/');
  final nonExistingUrl = Uri.parse('https://leancode.co/non-existing-path');
  final manifestUrl = Uri.parse('https://leancode.co/manifest.json');

  group('LoggingHttpClient', () {
    late LoggingHttpClient loggingHttpClient;

    setUp(() {
      loggingHttpClient = LoggingHttpClient();
    });

    test('send a http request through logging http client and log it',
        () async {
      await loggingHttpClient.get(leancodeWebsiteUrl);
      expectLater(
        loggingHttpClient.logStream,
        emits(const TypeMatcher<List<RequestLogRecord>>()),
      );
    });
  });

  group('DebugPageController', () {
    late DebugPageController controller;
    late LoggingHttpClient loggingHttpClient;

    setUp(
      () {
        registerFallbackValue(http.Request('GET', Uri()));

        final mockClient = MockHttpClient();

        void registerResponseForUri(Uri uri, int statusCode,
            [String? response]) {
          when(() => mockClient.send(
                any(that: predicate<http.BaseRequest>((r) => r.url == uri)),
              )).thenAnswer(
            (_) async => http.StreamedResponse(
              Stream.value(utf8.encode(response ?? '')),
              statusCode,
            ),
          );
        }

        registerResponseForUri(leancodeWebsiteUrl, 200);
        registerResponseForUri(nonExistingUrl, 404);
        registerResponseForUri(manifestUrl, 200, 'manifest content');

        loggingHttpClient = LoggingHttpClient(client: mockClient);
        controller = DebugPageController(loggingHttpClient: loggingHttpClient);
      },
    );

    test('log a single request', () async {
      await loggingHttpClient.get(leancodeWebsiteUrl);
      expect(
        controller.requestsLogs,
        equals([const TypeMatcher<RequestLogRecord>()]),
      );
    });

    test('filter requests by status', () async {
      await Future.wait([
        loggingHttpClient.get(leancodeWebsiteUrl),
        loggingHttpClient.get(nonExistingUrl),
      ]);

      controller.requestsFilters.value = [
        const RequestStatusFilter(desiredStatus: RequestStatus.success)
      ];

      TestWidgetsFlutterBinding.instance.addPostFrameCallback((_) {
        expect(controller.requestsLogs.length, 1);
      });
    });

    test('filter requests by searching', () async {
      await Future.wait([
        loggingHttpClient.get(leancodeWebsiteUrl),
        loggingHttpClient.get(nonExistingUrl),
        loggingHttpClient.get(manifestUrl),
      ]);

      controller.requestsFilters.value = [
        const RequestSearchFilter(
          type: RequestSearchType.body,
          phrase: '22',
        ),
      ];

      await Future.delayed(Duration(seconds: 1));
      expect(controller.requestsLogs.length, 1);

      TestWidgetsFlutterBinding.instance.addPostFrameCallback((_) {
        expect(controller.requestsLogs.length, 1);
      });
    });
  });
}
