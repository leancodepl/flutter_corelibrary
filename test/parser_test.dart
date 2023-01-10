import 'package:flutter_test/flutter_test.dart';
import 'package:leancode_markup/src/parser/lexer.dart';
import 'package:leancode_markup/src/parser/markup_parser.dart';
import 'package:leancode_markup/src/parser/tagged_text.dart';
import 'package:leancode_markup/src/parser/tokens.dart';

void main() {
  group('Parser parses tokens', () {
    List<TaggedText> parse(Tokens tokens) => parseTokens(tokens, '').toList();

    test('with simple tag', () {
      final parserResult = parse(const [
        Token.tagOpen('b'),
        Token.text('Bold, text'),
        Token.tagClose('b'),
      ]);

      const expected = [
        TaggedText(
          'Bold, text',
          tags: {'b'},
        ),
      ];
      expect(parserResult, expected);
    });

    test('with simple tag, and text on the end', () {
      final parserResult = parse(const [
        Token.tagOpen('b'),
        Token.text('Bold, text'),
        Token.tagClose('b'),
        Token.text(' with text'),
      ]);

      const expected = [
        TaggedText(
          'Bold, text',
          tags: {'b'},
        ),
        TaggedText(' with text'),
      ];
      expect(parserResult, expected);
    });

    test('with nested tags', () {
      final parserResult = parse(const [
        Token.text('Start '),
        Token.tagOpen('i'),
        Token.tagOpen('b'),
        Token.text('Italic, bold text'),
        Token.tagClose('b'),
        Token.tagClose('i'),
      ]);

      const expected = [
        TaggedText('Start '),
        TaggedText('Italic, bold text', tags: {'i', 'b'}),
      ];
      expect(parserResult, expected);
    });

    test('long text with nested tags, escape chars and new lines', () {
      final parserResult = parse(const [
        Token.text('Start '),
        Token.tagOpen('u'),
        Token.tagOpen('i'),
        Token.tagOpen('b'),
        Token.text('Italic, bold, underline text'),
        Token.tagClose('b'),
        Token.tagClose('i'),
        Token.text('solo underline'),
        Token.tagClose('u'),
        Token.text(r'\escapeChar end.'),
      ]);

      const expected = [
        TaggedText('Start '),
        TaggedText('Italic, bold, underline text', tags: {'u', 'i', 'b'}),
        TaggedText('solo underline', tags: {'u'}),
        TaggedText(r'\escapeChar end.'),
      ];
      expect(parserResult, expected);
    });
  });
}
