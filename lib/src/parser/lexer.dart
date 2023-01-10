import 'package:leancode_markup/src/parser/tokens.dart';
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

  Parser<Token> tagOpeningToken() => seq4(
        char('['),
        pattern('a-z').plus(),
        seq2(char('='), ref0(quotedString))
            .optional()
            .map((value) => value?.second),
        char(']'),
      ).map4((_, tag, param, ___) => Token.tagOpen(tag.join(), param));

  Parser<Token> tagClosingToken() => seq3(
        string('[/'),
        pattern('a-z').plus(),
        char(']'),
      ).map3((_, tag, ___) => Token.tagClose(tag.join()));

  Parser<String> characterPrimitive() => [
        ref0(characterNormal),
        ref0(() => characterEscape(_textEscapeChars)),
      ].toChoiceParser();

  Parser<String> characterNormal() => pattern(r'^[\');

  Parser<String> characterEscape(Map<String, String> escapeMap) => seq2(
        char(r'\'),
        anyOf(escapeMap.keys.join()),
      ).map2((_, char) => escapeMap[char]!);

  Parser<String> quotedString() => seq3(
        char('"'),
        [
          ref0(() => characterEscape(_quotedStringEscapeChars)),
          pattern(r'^"\'),
        ].toChoiceParser().star(),
        char('"'),
      ).map3((_, content, __) => content.join());

  static const _commonEscapeChars = {
    r'\': r'\',
    'b': '\b',
    'f': '\f',
    'n': '\n',
    'r': '\r',
    't': '\t',
  };
  static const _textEscapeChars = {
    '[': '[',
    ..._commonEscapeChars,
  };
  static const _quotedStringEscapeChars = {
    '"': '"',
    ..._commonEscapeChars,
  };
}

// TODO: at this point its debetable whether this is a lexer

final lexer = MarkupDefinition().build<Tokens>();
