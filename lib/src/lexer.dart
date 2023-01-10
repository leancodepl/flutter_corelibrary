import 'package:leancode_markup/src/tokens.dart';
import 'package:petitparser/petitparser.dart' hide Token;

typedef Tokens = List<Token>;

class MarkupDefinition extends GrammarDefinition<Tokens> {
  @override
  Parser<Tokens> start() => ref0(value).end();

  Parser<Tokens> value() => [
        tagOpeningToken(),
        tagClosingToken(),
        textToken(),
      ].toChoiceParser().star();

  Parser<Token> textToken() => [
        characterNormal(),
        characterPrimitive(),
      ].toChoiceParser().plus().map((value) => Token.text(value.join()));

  Parser<Token> tagOpeningToken() => seq3(
        char('['),
        pattern('a-z').plus(),
        char(']'),
      ).map3((_, tag, ___) => Token.tagOpen(tag.join()));

  Parser<Token> tagClosingToken() => seq3(
        string('[/'),
        pattern('a-z').plus(),
        char(']'),
      ).map3((_, tag, ___) => Token.tagClose(tag.join()));

  Parser<String> characterPrimitive() => [
        ref0(characterNormal),
        ref0(characterEscape),
      ].toChoiceParser();

  Parser<String> characterNormal() => pattern(r'^[\');

  Parser<String> characterEscape() => seq2(
        char(r'\'),
        anyOf(_markupEscapeChars.keys.join()),
      ).map2((_, char) => _markupEscapeChars[char]!);

  static const _markupEscapeChars = {
    r'\': r'\',
    '[': '[',
    'b': '\b',
    'f': '\f',
    'n': '\n',
    'r': '\r',
    't': '\t',
  };
}

final lexer = MarkupDefinition().build<Tokens>();
