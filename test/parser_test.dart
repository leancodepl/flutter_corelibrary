import 'dart:collection';

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
        Token.tagOpen('b'),
        Token.text('Bold, text'),
        Token.tagClose('b'),
      ]);

      final expected = [
        TaggedText(
          'Bold, text',
          tags: LinkedHashMap.from(<String, String?>{'b': null}),
        ),
      ];
      expect(result, expected);
    });

    test('with simple tag, and text on the end', () {
      final result = parse(const [
        Token.tagOpen('b'),
        Token.text('Bold, text'),
        Token.tagClose('b'),
        Token.text(' with text'),
      ]);

      final expected = [
        TaggedText(
          'Bold, text',
          tags: LinkedHashMap.from(<String, String?>{'b': null}),
        ),
        TaggedText(' with text'),
      ];
      expect(result, expected);
    });

    test('with nested tags', () {
      final result = parse(const [
        Token.text('Start '),
        Token.tagOpen('i'),
        Token.tagOpen('b'),
        Token.text('Italic, bold text'),
        Token.tagClose('b'),
        Token.tagClose('i'),
      ]);

      final expected = [
        TaggedText('Start '),
        TaggedText(
          'Italic, bold text',
          tags: LinkedHashMap.from(<String, String?>{'i': null, 'b': null}),
        ),
      ];
      expect(result, expected);
    });

    test('with tags with a parameter', () {
      final result = parse(const [
        Token.text('Start '),
        Token.tagOpen('i'),
        Token.tagOpen('url', 'https://leancode.co'),
        Token.tagOpen('b'),
        Token.text('Italic, bold text'),
        Token.tagClose('b'),
        Token.tagClose('url'),
        Token.tagClose('i'),
      ]);

      final expected = [
        TaggedText('Start '),
        TaggedText(
          'Italic, bold text',
          tags: LinkedHashMap.from(<String, String?>{
            'i': null,
            'url': 'https://leancode.co',
            'b': null,
          }),
        ),
      ];
      expect(result, expected);
    });

    test('with preserved order of tags', () {
      final result = parse(const [
        Token.text('Start '),
        Token.tagOpen('i'),
        Token.tagOpen('url', 'https://leancode.co'),
        Token.tagOpen('b'),
        Token.text('Italic, bold text'),
        Token.tagClose('b'),
        Token.tagClose('url'),
        Token.tagClose('i'),
      ]);

      final expected = [
        TaggedText('Start '),
        TaggedText(
          'Italic, bold text',
          tags: LinkedHashMap.from(<String, String?>{
            'url': 'https://leancode.co',
            'i': null,
            'b': null,
          }),
        ),
      ];
      expect(result, isNot(expected));
    });

    test('long text with nested tags, escape chars and new lines', () {
      final result = parse(const [
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

      final expected = [
        TaggedText('Start '),
        TaggedText(
          'Italic, bold, underline text',
          tags: LinkedHashMap.from(
            <String, String?>{'u': null, 'i': null, 'b': null},
          ),
        ),
        TaggedText(
          'solo underline',
          tags: LinkedHashMap.from(<String, String?>{'u': null}),
        ),
        TaggedText(r'\escapeChar end.'),
      ];
      expect(result, expected);
    });
  });
}
