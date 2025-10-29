import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:leancode_debug_page/src/core/debug_page_controller.dart';
import 'package:leancode_debug_page/src/core/filters/request_filters.dart';
import 'package:leancode_debug_page/src/core/logging_http_client.dart';
import 'package:leancode_debug_page/src/models/request_log_record.dart';
import 'package:leancode_debug_page/src/ui/logs_inspector/requests/requests_tab_filters_menu.dart';
import 'package:mocktail/mocktail.dart';

import '../util/mock_http_client.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final homeUrl = Uri.parse('https://leancode.co/');
  final nonExistingUrl = Uri.parse('https://leancode.co/non-existing-path');
  final birdsQuestionsUrl = Uri.parse(
    'https://leancode.co/birds-questions.json',
  );
  final elephantsUrl = Uri.parse('https://leancode.co/elephants-funfacts.json');

  group('DebugPageController - requests:', () {
    late DebugPageController controller;
    late LoggingHttpClient loggingHttpClient;

    setUp(
      () {
        registerFallbackValue(http.Request('GET', Uri()));

        final mockClient = MockHttpClient();

        void registerResponseForUri(
          Uri uri,
          int statusCode, [
          String? response,
        ]) {
          when(
            () => mockClient.send(
              any(that: predicate<http.BaseRequest>((r) => r.url == uri)),
            ),
          ).thenAnswer(
            (_) async => http.StreamedResponse(
              Stream.value(utf8.encode(response ?? '')),
              statusCode,
            ),
          );
        }

        registerResponseForUri(homeUrl, 200);
        registerResponseForUri(
          nonExistingUrl,
          404,
          'Not found',
        );
        registerResponseForUri(
          birdsQuestionsUrl,
          200,
          'why do birds sleep standing up?',
        );
        registerResponseForUri(
          elephantsUrl,
          200,
          'elephants eat around 150kg of food daily',
        );

        loggingHttpClient = LoggingHttpClient(client: mockClient);
        controller = DebugPageController(
          loggingHttpClient: loggingHttpClient,
          showOnShake: false,
          navigatorKey: GlobalKey(),
        );
      },
    );

    test('log a single request', () async {
      await loggingHttpClient.get(homeUrl);
      expect(
        controller.requestsLogs,
        equals([const TypeMatcher<RequestLogRecord>()]),
      );
    });

    test('filter requests by status', () async {
      await Future.wait([
        loggingHttpClient.get(homeUrl),
        loggingHttpClient.get(nonExistingUrl),
      ]);

      controller.requestsFilters.value = [
        const RequestStatusFilter(desiredStatus: RequestStatus.success),
      ];

      await Future<void>.delayed(Duration.zero);
      expect(controller.requestsLogs.length, 1);
    });

    test('search requests by body', () async {
      await Future.wait([
        loggingHttpClient.get(homeUrl),
        loggingHttpClient.get(nonExistingUrl),
        loggingHttpClient.get(birdsQuestionsUrl),
      ]);

      controller.requestsFilters.value = [
        const RequestSearchFilter(
          type: RequestSearchType.body,
          phrase: 'birds',
        ),
      ];

      await Future<void>.delayed(Duration.zero);
      expect(controller.requestsLogs.length, 1);
    });

    test('filter requests by status and search by body at the same time',
        () async {
      await Future.wait([
        loggingHttpClient.get(homeUrl),
        loggingHttpClient.get(nonExistingUrl),
        loggingHttpClient.get(birdsQuestionsUrl),
      ]);

      controller.requestsFilters.value = [
        const RequestStatusFilter(desiredStatus: RequestStatus.clientError),
        const RequestSearchFilter(
          type: RequestSearchType.body,
          phrase: 'found',
        ),
      ];

      await Future<void>.delayed(Duration.zero);
      expect(controller.requestsLogs.length, 1);
    });

    test('clear requests logs', () async {
      await Future.wait([
        loggingHttpClient.get(homeUrl),
        loggingHttpClient.get(nonExistingUrl),
      ]);

      expect(controller.requestsLogs.length, 2);

      controller.clearRequestsLogs();

      await Future<void>.delayed(Duration.zero);
      expect(controller.requestsLogs, isEmpty);
    });
  });
}
