import 'package:flutter_test/flutter_test.dart';
import 'package:leancode_markup/src/parser/lexer.dart';
import 'package:leancode_markup/src/parser/markup_parser.dart';
import 'package:leancode_markup/src/parser/tagged_text.dart';
import 'package:leancode_markup/src/parser/tokens.dart';

void main() {
  group('Parser parses tokens', () {
    List<TaggedText> parse(Tokens tokens) => parseTokens(tokens, '').toList();

    test('with simple tag', () {
      final result = parse(const [
        TagOpenToken('b'),
        TextToken('Bold, text'),
        TagCloseToken('b'),
      ]);

      final expected = [
        TaggedText(
          'Bold, text',
          tags: const [MarkupTag('b')],
        ),
      ];
      expect(result, expected);
    });

    test('with simple tag, and text on the end', () {
      final result = parse(const [
        TagOpenToken('b'),
        TextToken('Bold, text'),
        TagCloseToken('b'),
        TextToken(' with text'),
      ]);

      final expected = [
        TaggedText(
          'Bold, text',
          tags: const [MarkupTag('b')],
        ),
        TaggedText(' with text'),
      ];
      expect(result, expected);
    });

    test('with nested tags', () {
      final result = parse(const [
        TextToken('Start '),
        TagOpenToken('i'),
        TagOpenToken('b'),
        TextToken('Italic, bold text'),
        TagCloseToken('b'),
        TagCloseToken('i'),
      ]);

      final expected = [
        TaggedText('Start '),
        TaggedText(
          'Italic, bold text',
          tags: [const MarkupTag('i'), const MarkupTag('b')],
        ),
      ];
      expect(result, expected);
    });

    test('with tags with a parameter', () {
      final result = parse(const [
        TextToken('Start '),
        TagOpenToken('i'),
        TagOpenToken('url', 'https://leancode.co'),
        TagOpenToken('b'),
        TextToken('Italic, bold text'),
        TagCloseToken('b'),
        TagCloseToken('url'),
        TagCloseToken('i'),
      ]);

      final expected = [
        TaggedText('Start '),
        TaggedText(
          'Italic, bold text',
          tags: [
            const MarkupTag('i'),
            const MarkupTag('url', 'https://leancode.co'),
            const MarkupTag('b'),
          ],
        ),
      ];
      expect(result, expected);
    });

    test('with preserved order of tags', () {
      final result = parse(const [
        TextToken('Start '),
        TagOpenToken('i'),
        TagOpenToken('url', 'https://leancode.co'),
        TagOpenToken('b'),
        TextToken('Italic, bold text'),
        TagCloseToken('b'),
        TagCloseToken('url'),
        TagCloseToken('i'),
      ]);

      final expected = [
        TaggedText('Start '),
        TaggedText(
          'Italic, bold text',
          tags: [
            const MarkupTag('url', 'https://leancode.co'),
            const MarkupTag('i'),
            const MarkupTag('b'),
          ],
        ),
      ];
      expect(result, isNot(expected));
    });

    test('long text with nested tags, escape chars and new lines', () {
      final result = parse(const [
        TextToken('Start '),
        TagOpenToken('u'),
        TagOpenToken('i'),
        TagOpenToken('b'),
        TextToken('Italic, bold, underline text'),
        TagCloseToken('b'),
        TagCloseToken('i'),
        TextToken('solo underline'),
        TagCloseToken('u'),
        TextToken(r'\escapeChar end.'),
      ]);

      final expected = [
        TaggedText('Start '),
        TaggedText(
          'Italic, bold, underline text',
          tags: [
            const MarkupTag('u'),
            const MarkupTag('i'),
            const MarkupTag('b'),
          ],
        ),
        TaggedText(
          'solo underline',
          tags: [
            const MarkupTag('u'),
          ],
        ),
        TaggedText(r'\escapeChar end.'),
      ];
      expect(result, expected);
    });
  });
}
