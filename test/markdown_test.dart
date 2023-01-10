import 'package:flutter_test/flutter_test.dart';
import 'package:leancode_markup/src/lexer.dart';
import 'package:leancode_markup/src/markup_parser.dart';
import 'package:leancode_markup/src/text_with_attributes.dart';

void main() {
  group('Parser parses tokens', () {
    final parser = MarkupParser();

    test('with simple tag', () {
      const text = '[b]Bold, text[/b]';
      final lexerResult = lexer.parse(text);

      if (lexerResult.isSuccess) {
        final parserResult = parser.parse(lexerResult.value);
        final expected = <TextWithAttributes>[
          const TextWithAttributes(
            text: 'Bold, text',
            attributes: {Bold()},
          ),
        ];
        expect(parserResult, expected);
      } else {
        throw Exception('Lexer could not parse input text');
      }
    });

    test('with simple tag, and text on the end', () {
      const text = '[b]Bold, text[/b] with text';
      final lexerResult = lexer.parse(text);

      if (lexerResult.isSuccess) {
        final parserResult = parser.parse(lexerResult.value);
        final expected = <TextWithAttributes>[
          const TextWithAttributes(
            text: 'Bold, text',
            attributes: {Bold()},
          ),
          const TextWithAttributes(
            text: 'with text',
          ),
        ];
        expect(parserResult, expected);
      } else {
        throw Exception('Lexer could not parse input text');
      }
    });

    test('with nested tags', () {
      const text = 'Start [i][b]Italic, bold text[/b][/i]';
      final lexerResult = lexer.parse(text);

      if (lexerResult.isSuccess) {
        final parserResult = parser.parse(lexerResult.value);
        final expected = <TextWithAttributes>[
          const TextWithAttributes(
            text: 'Start ',
          ),
          const TextWithAttributes(
            text: 'Italic, bold text',
            attributes: {
              Italic(),
              Bold(),
            },
          ),
        ];
        expect(parserResult, expected);
      } else {
        throw Exception('Lexer could not parse input text');
      }
    });

    test('long text with nested tags, escape chars and new lines', () {
      // const text = 'Start [u][b][i]Lorem ipsum[/b][/i]end[/u]';
      const text =
          r'Start [u][i][b]Italic, bold, underline text[/b][/i]solo underline[/u]\escapeChar end.';
      final lexerResult = lexer.parse(text);

      if (lexerResult.isSuccess) {
        final parserResult = parser.parse(lexerResult.value);

        final expected = <TextWithAttributes>[
          const TextWithAttributes(
            text: 'Start ',
          ),
          const TextWithAttributes(
            text: 'Italic, bold, underline text',
            attributes: {
              Bold(),
              Italic(),
              Underline(),
            },
          ),
          const TextWithAttributes(
            text: 'solo underline',
            attributes: {
              Underline(),
            },
          ),
          const TextWithAttributes(
            text: r'\escapeChar end.',
          ),
        ];
        expect(parserResult, expected);
      } else {
        throw Exception('Lexer could not parse input text');
      }
    });
  });
}
