import 'package:flutter_test/flutter_test.dart';
import 'package:leancode_markup/src/parser/markup_parser.dart';
import 'package:leancode_markup/src/parser/tokens.dart';

void main() {
  group('Clean up parses tokens with ParsingAloneTagTactic.hide', () {
    List<Token> cleanUp(List<Token> tokens) =>
        cleanUpTokens(tokens, '', tactic: ParsingAloneTagTactic.hide);

    test('just text', () {
      final result = cleanUp(const [TextToken('Bold, text')]);

      const expected = [TextToken('Bold, text')];

      expect(result, expected);
    });

    test('with simple valid tag', () {
      final result = cleanUp(
        const [
          TagOpenToken('b'),
          TextToken('Bold, text'),
          TagCloseToken('b'),
        ],
      );

      const expected = [
        TagOpenToken('b'),
        TextToken('Bold, text'),
        TagCloseToken('b'),
      ];

      expect(result, expected);
    });

    test('with invalid opening tag', () {
      final result = cleanUp(
        const [
          TagOpenToken('b'),
          TextToken('Bold, text'),
        ],
      );

      const expected = [
        TextToken('Bold, text'),
      ];

      expect(result, expected);
    });

    test('with invalid closing tag', () {
      final result = cleanUp(
        const [
          TextToken('Bold, text'),
          TagCloseToken('b'),
        ],
      );

      const expected = [
        TextToken('Bold, text'),
      ];

      expect(result, expected);
    });

    test('with valid pair tag and one invalid closing tag', () {
      final result = cleanUp(
        const [
          TagOpenToken('u'),
          TextToken('Underline, text'),
          TagCloseToken('b'),
          TagCloseToken('u'),
        ],
      );

      const expected = [
        TagOpenToken('u'),
        TextToken('Underline, text'),
        TagCloseToken('u'),
      ];

      expect(result, expected);
    });

    test('with valid pair tag and one invalid opening tag', () {
      final result = cleanUp(
        const [
          TagOpenToken('b'),
          TagOpenToken('u'),
          TextToken('Underline, text'),
          TagCloseToken('b'),
        ],
      );

      const expected = [
        TagOpenToken('b'),
        TextToken('Underline, text'),
        TagCloseToken('b'),
      ];

      expect(result, expected);
    });
  });

  group('Clean up parses tokens with ParsingAloneTagTactic.show', () {
    List<Token> cleanUp(List<Token> tokens) =>
        // ignore: avoid_redundant_argument_values
        cleanUpTokens(tokens, '', tactic: ParsingAloneTagTactic.show);

    test('just text', () {
      final result = cleanUp(const [TextToken('Bold, text')]);

      const expected = [TextToken('Bold, text')];

      expect(result, expected);
    });

    test('with simple valid tag', () {
      final result = cleanUp(
        const [
          TagOpenToken('b'),
          TextToken('Bold, text'),
          TagCloseToken('b'),
        ],
      );

      const expected = [
        TagOpenToken('b'),
        TextToken('Bold, text'),
        TagCloseToken('b'),
      ];

      expect(result, expected);
    });

    test('with invalid opening tag', () {
      final result = cleanUp(
        const [
          TagOpenToken('b'),
          TextToken('Bold, text'),
        ],
      );

      const expected = [
        TextToken('[b]'),
        TextToken('Bold, text'),
      ];

      expect(result, expected);
    });

    test('with invalid closing tag', () {
      final result = cleanUp(
        const [
          TextToken('Bold, text'),
          TagCloseToken('b'),
        ],
      );

      const expected = [
        TextToken('Bold, text'),
        TextToken('[/b]'),
      ];

      expect(result, expected);
    });

    test('with valid pair tag and one invalid closing tag', () {
      final result = cleanUp(
        const [
          TagOpenToken('u'),
          TextToken('Underline, text'),
          TagCloseToken('b'),
          TagCloseToken('u'),
        ],
      );

      const expected = [
        TagOpenToken('u'),
        TextToken('Underline, text'),
        TextToken('[/b]'),
        TagCloseToken('u'),
      ];

      expect(result, expected);
    });

    test('with valid pair tag and one invalid opening tag', () {
      final result = cleanUp(
        const [
          TagOpenToken('b'),
          TagOpenToken('u'),
          TextToken('Underline, text'),
          TagCloseToken('b'),
        ],
      );

      const expected = [
        TagOpenToken('b'),
        TextToken('[u]'),
        TextToken('Underline, text'),
        TagCloseToken('b'),
      ];

      expect(result, expected);
    });
  });
}
