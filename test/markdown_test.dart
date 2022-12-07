import 'package:flutter_test/flutter_test.dart';
import 'package:leancode_markdown/lexer.dart';
import 'package:leancode_markdown/src/markdown_parser.dart';
import 'package:leancode_markdown/src/text_with_attributes.dart';

void main() {
  final lexer = MarkdownDefinition().build<Markdown>();

  group('Lexer parses text', () {
    test('with one tag', () {
      const text = 'a[i]bba[/i]';
      final result = lexer.parse(text);
      final expected = <Token>[
        const TextToken('a'),
        ItalicA.open(),
        const TextToken('bba'),
        ItalicA.close(),
      ];
      expect(result.value, expected);
    });

    test('with nested tags', () {
      const text = 'bb[i][b]Italic, bold text[/b][/i]';
      final result = lexer.parse(text);
      final expected = <Token>[
        const TextToken('bb'),
        ItalicA.open(),
        BoldA.open(),
        const TextToken('Italic, bold text'),
        BoldA.close(),
        ItalicA.close(),
      ];
      expect(result.value, expected);
    });

    test('with char escape', () {
      const text = 'bb[b]Italic, bold text\\[/b]';
      final result = lexer.parse(text);
      final expected = <Token>[
        const TextToken('bb'),
        BoldA.open(),
        const TextToken('Italic, bold text[/b]'),
      ];
      expect(result.value, expected);
    });
  });

  group('Parser parses tokens', () {
    final parser = MarkdownParser();

    test('compate two italics', () {
      const int1 = Italic();
      const int2 = Italic();

      final areEqual = int1 == int2;

      expect(areEqual, true);
    });

    test('with simple tag', () {
      const text = '[b]Bold, text[/b]';
      final lexerResult = lexer.parse(text);

      if (lexerResult.isSuccess) {
        final parserResult = parser.parse(lexerResult.value as List<Token>);
        final expected = <TextWithAttributes>[
          const TextWithAttributes(
            text: 'Bold, text',
            attributes: {Bold()},
          ),
        ];
        expect(parserResult, expected);
      } else {
        throw (Exception('Lexer could not parse input text'));
      }
    });

    test('with simple tag, and text on the end', () {
      const text = '[b]Bold, text[/b] with text';
      final lexerResult = lexer.parse(text);

      if (lexerResult.isSuccess) {
        final parserResult = parser.parse(lexerResult.value as List<Token>);
        final expected = <TextWithAttributes>[
          const TextWithAttributes(
            text: 'Bold, text',
            attributes: {Bold()},
          ),
          const TextWithAttributes(
            text: 'with text',
            attributes: {},
          ),
        ];
        expect(parserResult, expected);
      } else {
        throw (Exception('Lexer could not parse input text'));
      }
    });

    test('with nested tags', () {
      const text = 'Start [i][b]Italic, bold text[/b][/i]';
      final lexerResult = lexer.parse(text);

      if (lexerResult.isSuccess) {
        final parserResult = parser.parse(lexerResult.value as List<Token>);
        final expected = <TextWithAttributes>[
          const TextWithAttributes(
            text: 'Start ',
            attributes: {},
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
        throw (Exception('Lexer could not parse input text'));
      }
    });

    test('long text with nested tags, escape chars and new lines', () {
      // const text = 'Start [u][b][i]Lorem ipsum[/b][/i]end[/u]';
      const text =
          'Start [u][i][b]Italic, bold, underline text[/b][/i]solo underline[/u]\\escapeChar end.';
      final lexerResult = lexer.parse(text);

      if (lexerResult.isSuccess) {
        final parserResult = parser.parse(lexerResult.value as List<Token>);

        final expected = <TextWithAttributes>[
          const TextWithAttributes(
            text: 'Start ',
            attributes: {},
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
            text: '\\escapeChar end.',
            attributes: {},
          ),
        ];
        expect(parserResult, expected);
      } else {
        throw (Exception('Lexer could not parse input text'));
      }
    });
  });
}
