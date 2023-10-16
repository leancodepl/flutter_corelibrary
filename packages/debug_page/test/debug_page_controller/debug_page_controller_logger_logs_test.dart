import 'package:debug_page/src/core/debug_page_controller.dart';
import 'package:debug_page/src/core/filters/logger_filters.dart';
import 'package:debug_page/src/core/logging_http_client.dart';
import 'package:debug_page/src/ui/logs_inspector/logger/logger_tab_filters_menu.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:logging/logging.dart';

import '../util/mock_http_client.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('DebugPageController - logs:', () {
    late DebugPageController controller;

    setUp(
      () {
        final mockClient = MockHttpClient();
        controller = DebugPageController(
          loggingHttpClient: LoggingHttpClient(client: mockClient),
        );

        Logger.root.level = Level.ALL;

        Logger('TestLogger')
          ..info('Some info logs')
          ..fine('Some fine logs')
          ..finer('Some finer logs')
          ..finest('Some finest logs')
          ..severe('Some severe logs');

        Logger('OtherLogger')
          ..info('Info from another logger')
          ..severe('Some severe logs from another logger');
      },
    );

    test('logs logger logs', () async {
      await expectLater(
        controller.loggerLogStream,
        emits(const TypeMatcher<List<LogRecord>>()),
      );
    });

    test('filter logs by <=FINE level', () async {
      controller.loggerFilters.value = [
        const LoggerLevelFilter(desiredLevel: Level.FINE),
      ];

      await Future<void>.delayed(Duration.zero);
      // Should include logs at levels: fine, finer, finest
      expect(controller.loggerLogs.length, 3);
    });

    test('filter logs by SEVERE level', () async {
      controller.loggerFilters.value = [
        const LoggerLevelFilter(desiredLevel: Level.SEVERE),
      ];

      await Future<void>.delayed(Duration.zero);
      expect(controller.loggerLogs.length, 2);
    });

    test('filter logs by logger name search', () async {
      controller.loggerFilters.value = [
        const LoggerSearchFilter(
          phrase: 'OtherLogger',
          type: LogSearchType.loggerName,
        ),
      ];

      await Future<void>.delayed(Duration.zero);
      expect(controller.loggerLogs.length, 2);
    });

    test('filter logs by both logger name and log level', () async {
      controller.loggerFilters.value = [
        const LoggerSearchFilter(
          phrase: 'OtherLogger',
          type: LogSearchType.loggerName,
        ),
        const LoggerLevelFilter(desiredLevel: Level.SEVERE),
      ];

      await Future<void>.delayed(Duration.zero);
      expect(controller.loggerLogs.length, 1);
    });

    test('filter logs by both log message and log level', () async {
      controller.loggerFilters.value = [
        const LoggerSearchFilter(
          phrase: 'another',
          type: LogSearchType.logMessage,
        ),
        const LoggerLevelFilter(desiredLevel: Level.SEVERE),
      ];

      await Future<void>.delayed(Duration.zero);
      expect(controller.loggerLogs.length, 1);
    });
  });
}
