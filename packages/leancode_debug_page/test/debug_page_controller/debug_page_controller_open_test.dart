import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:leancode_debug_page/src/core/debug_page_controller.dart';
import 'package:leancode_debug_page/src/core/logging_http_client.dart';
import 'package:leancode_debug_page/src/ui/logs_inspector/logs_inspector.dart';

import '../util/mock_http_client.dart';

void main() {
  group('DebugPageController - open:', () {
    late DebugPageController controller;
    late GlobalKey<NavigatorState> navigatorKey;

    setUp(() {
      navigatorKey = GlobalKey();
      controller = DebugPageController(
        loggingHttpClient: LoggingHttpClient(client: MockHttpClient()),
        showOnShake: false,
        navigatorKey: navigatorKey,
      );
    });

    tearDown(() => controller.dispose());

    Future<void> pumpApp(WidgetTester tester) => tester.pumpWidget(
      MaterialApp(
        navigatorKey: navigatorKey,
        navigatorObservers: [controller.navigatorObserver],
        home: const Scaffold(),
      ),
    );

    testWidgets('does not open a second debug page when one is already open', (
      tester,
    ) async {
      await pumpApp(tester);

      controller.open();
      await tester.pumpAndSettle();

      expect(controller.isOpen.value, isTrue);
      expect(find.byType(LogsInspector), findsOneWidget);

      controller.open();
      await tester.pumpAndSettle();

      expect(find.byType(LogsInspector), findsOneWidget);

      // A single pop leaves no debug page behind.
      navigatorKey.currentState!.pop();
      await tester.pumpAndSettle();

      expect(controller.isOpen.value, isFalse);
      expect(find.byType(LogsInspector), findsNothing);
    });

    testWidgets('can be reopened after being closed', (tester) async {
      await pumpApp(tester);

      controller.open();
      await tester.pumpAndSettle();
      controller.close();
      await tester.pumpAndSettle();

      controller.open();
      await tester.pumpAndSettle();

      expect(controller.isOpen.value, isTrue);
      expect(find.byType(LogsInspector), findsOneWidget);
    });
  });
}
