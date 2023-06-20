import 'package:flutter_test/flutter_test.dart';
import 'package:leancode_markup/src/parser/lexer.dart';
import 'package:leancode_markup/src/parser/tokens.dart';
import 'package:petitparser/reflection.dart';

void main() {
  group('Lexer tokenizes text', () {
    test('detect common problems', () {
      expect(linter(lexer), isEmpty);
    });

    test('with one tag', () {
      const text = 'a[i]bba[/i]';
      final result = lexer.parse(text);

      const expected = [
        TextToken('a'),
        TagOpenToken('i'),
        TextToken('bba'),
        TagCloseToken('i'),
      ];
      expect(result.value, expected);
    });

    test('with nested tags', () {
      const text = 'bb[i][b]Italic, bold text[/b][/i]';
      final result = lexer.parse(text);

      const expected = [
        TextToken('bb'),
        TagOpenToken('i'),
        TagOpenToken('b'),
        TextToken('Italic, bold text'),
        TagCloseToken('b'),
        TagCloseToken('i'),
      ];
      expect(result.value, expected);
    });

    test('with escaped opening tag', () {
      const text = r'bb\[b]Italic, bold text[/b]';
      final result = lexer.parse(text);

      const expected = [
        TextToken('bb[b]Italic, bold text'),
        TagCloseToken('b'),
      ];
      expect(result.value, expected);
    });

    test('with escaped closing tag', () {
      const text = r'bb[b]Italic, bold text\[/b]';
      final result = lexer.parse(text);

      const expected = [
        TextToken('bb'),
        TagOpenToken('b'),
        TextToken('Italic, bold text[/b]'),
      ];
      expect(result.value, expected);
    });

    test('while preserving text whitespace', () {
      const text = '  bb  \t [b] \n Italic, bold text  [/b] \n';
      final result = lexer.parse(text);

      const expected = [
        TextToken('  bb  \t '),
        TagOpenToken('b'),
        TextToken(' \n Italic, bold text  '),
        TagCloseToken('b'),
        TextToken(' \n'),
      ];
      expect(result.value, expected);
    });

    test('with tags with a parameter', () {
      const text = '[url="https://leancode.co"]cool site[/url]';
      final result = lexer.parse(text);

      const expected = [
        TagOpenToken('url', 'https://leancode.co'),
        TextToken('cool site'),
        TagCloseToken('url'),
      ];
      expect(result.value, expected);
    });

    test('with tags with a parameter which escapes quotes', () {
      const text = r'[url="https://le\"ancode.co\""]cool site[/url]';
      final result = lexer.parse(text);

      const expected = [
        TagOpenToken('url', 'https://le"ancode.co"'),
        TextToken('cool site'),
        TagCloseToken('url'),
      ];
      expect(result.value, expected);
    });

    test('with escape chars', () {
      const text = r'\b\f\n\r\t';
      final result = lexer.parse(text);

      const expected = [
        TextToken('\b\f\n\r\t'),
      ];
      expect(result.value, expected);
    });

    test('long text with nested tags, escape chars and new lines', () {
      const text =
          r'Start [u][i][b]Italic, bold, underline text[/b][/i]solo underline[/u]\\escapeChar end.';
      final result = lexer.parse(text);

      const expected = [
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
      ];
      expect(result.value, expected);
    });
  });
}
