import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:leancode_debug_page/src/models/request_log_record.dart';
import 'package:leancode_debug_page/src/ui/logs_inspector/logger/logger_log_tile.dart';
import 'package:leancode_debug_page/src/ui/logs_inspector/requests/request_log_tile.dart';
import 'package:logging/logging.dart';

void main() {
  // The tiles paint themselves with the debug page's own status colors, so they
  // have to stay legible under an app theme whose foreground does not contrast
  // with those.
  ThemeData hostileTheme(Brightness brightness) => ThemeData(
    colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.blue,
      brightness: brightness,
    ).copyWith(onSurface: const Color(0xFF808080)),
  );

  double contrastRatio(Color a, Color b) {
    final luminances = [a.computeLuminance(), b.computeLuminance()];

    return (luminances.reduce(max) + 0.05) / (luminances.reduce(min) + 0.05);
  }

  Future<void> pumpTile(
    WidgetTester tester,
    Brightness brightness,
    Widget tile,
  ) => tester.pumpWidget(
    MaterialApp(
      theme: hostileTheme(brightness),
      home: Scaffold(body: tile),
    ),
  );

  void expectLegibleTexts(WidgetTester tester, Type tileType) {
    final background = tester
        .widget<Material>(
          find.descendant(
            of: find.byType(tileType),
            matching: find.byType(Material),
          ),
        )
        .color!;

    final texts = find.descendant(
      of: find.byType(tileType),
      matching: find.byType(RichText),
    );
    expect(texts, findsWidgets);

    for (final text in tester.widgetList<RichText>(texts)) {
      expect(
        contrastRatio(text.text.style!.color!, background),
        greaterThanOrEqualTo(4.5),
        reason: 'the text "${text.text.toPlainText()}" is illegible',
      );
    }
  }

  for (final brightness in Brightness.values) {
    group('in a ${brightness.name} theme', () {
      for (final level in const [
        Level.FINEST,
        Level.FINE,
        Level.CONFIG,
        Level.INFO,
        Level.WARNING,
        Level.SEVERE,
        Level.SHOUT,
      ]) {
        testWidgets('a ${level.name} logger log tile is legible', (
          tester,
        ) async {
          await pumpTile(
            tester,
            brightness,
            LoggerLogTile(log: LogRecord(level, 'Message', 'TestLogger')),
          );

          expectLegibleTexts(tester, LoggerLogTile);
        });
      }

      for (final statusCode in const [200, 302, 404, 500, 0]) {
        testWidgets('a $statusCode request log tile is legible', (
          tester,
        ) async {
          await pumpTile(
            tester,
            brightness,
            RequestLogTile(
              log: RequestLogRecord(
                method: 'GET',
                url: Uri.parse('https://example.com/resource'),
                startTime: DateTime(2026),
                endTime: DateTime(2026),
                statusCode: statusCode,
                requestHeaders: const {},
                requestBody: null,
                responseHeaders: const {},
                responseBodyCompleter: Completer(),
              ),
              ignoredBasePath: null,
            ),
          );

          expectLegibleTexts(tester, RequestLogTile);
        });
      }
    });
  }
}
