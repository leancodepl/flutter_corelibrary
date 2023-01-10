import 'package:flutter_test/flutter_test.dart';
import 'package:leancode_markup/src/lexer.dart';
import 'package:leancode_markup/src/tokens.dart';

void main() {
  group('Lexer tokenizes text', () {
    test('with one tag', () {
      const text = 'a[i]bba[/i]';
      final result = lexer.parse(text);

      const expected = [
        Token.text('a'),
        Token.tagOpen('i'),
        Token.text('bba'),
        Token.tagClose('i'),
      ];
      expect(result.value, expected);
    });

    test('with nested tags', () {
      const text = 'bb[i][b]Italic, bold text[/b][/i]';
      final result = lexer.parse(text);

      const expected = [
        Token.text('bb'),
        Token.tagOpen('i'),
        Token.tagOpen('b'),
        Token.text('Italic, bold text'),
        Token.tagClose('b'),
        Token.tagClose('i'),
      ];
      expect(result.value, expected);
    });

    test('with escaped opening tag', () {
      const text = r'bb\[b]Italic, bold text[/b]';
      final result = lexer.parse(text);

      const expected = [
        Token.text('bb[b]Italic, bold text'),
        Token.tagClose('b'),
      ];
      expect(result.value, expected);
    });

    test('with escaped closing tag', () {
      const text = r'bb[b]Italic, bold text\[/b]';
      final result = lexer.parse(text);

      const expected = [
        Token.text('bb'),
        Token.tagOpen('b'),
        Token.text('Italic, bold text[/b]'),
      ];
      expect(result.value, expected);
    });

    test('while preserving text whitespace', () {
      const text = '  bb  \t [b] \n Italic, bold text  [/b] \n';
      final result = lexer.parse(text);

      const expected = [
        Token.text('  bb  \t '),
        Token.tagOpen('b'),
        Token.text(' \n Italic, bold text  '),
        Token.tagClose('b'),
        Token.text(' \n'),
      ];
      expect(result.value, expected);
    });
  });
}
