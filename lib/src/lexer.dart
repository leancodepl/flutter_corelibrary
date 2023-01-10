import 'package:leancode_markup/src/escape_characters.dart';
import 'package:petitparser/petitparser.dart';

class MarkupDefinition extends GrammarDefinition {
  @override
  Parser<List<Token>> start() => ref0(value).end();

  Parser<List<Token>> value() => [
        tagOpeningToken(),
        tagClosingToken(),
        textToken(),
      ].toChoiceParser().star();

  Parser<Token> textToken() => <Parser<String>>[
        characterNormal(),
        characterPrimitive(),
      ].toChoiceParser().plus().map((value) => TextToken(value.join()));

  Parser<Token> tagOpeningToken() => seq3(
        //TODO: add start of text
        char('['),
        pattern('a-z'),
        char(']'),
      ).trim().map3((__, tag, ___) => mapOpeningTag(tag));

  Parser<Token> tagClosingToken() => seq4(
        char('['),
        char('/'),
        pattern('a-z'),
        char(']'),
      ).trim().map4((_, __, tag, ___) => mapClosingTag(tag));

  Parser<String> characterPrimitive() => [
        ref0(characterNormal),
        ref0(characterEscape),
      ].toChoiceParser();

  Parser<String> characterNormal() => pattern('^[\\');

  Parser<String> characterEscape() => seq2(
        char('\\'),
        anyOf(markupEscapeStrings.keys.join()),
      ).map2((_, char) => markupEscapeStrings[char]!);

  //eventually, put this switch into lexer
  Token mapOpeningTag(String tag) {
    switch (tag) {
      case 'b':
        return BoldA.open();
      case 'i':
        return ItalicA.open();
      case 'u':
        return UnderlineA.open();
      default:
        throw ArgumentError();
    }
  }

  Token mapClosingTag(String tag) {
    switch (tag) {
      case 'b':
        return BoldA.close();
      case 'i':
        return ItalicA.close();
      case 'u':
        return UnderlineA.close();
      default:
        throw ArgumentError();
    }
  }
}

typedef Markup = Object?;

final lexer = MarkupDefinition().build<Markup>();

//Token holds information about text or opening
//or closing token like [b] or [/b] that identify start + end of Bold text
abstract class Token {
  const Token();
}

class TextToken extends Token {
  const TextToken(this.text);

  final String text;
  @override
  String toString() => text;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TextToken &&
          runtimeType == other.runtimeType &&
          text == other.text;

  @override
  int get hashCode => text.hashCode;
}

//OpenCloseToken is a
abstract class OpenCloseToken extends Token {
  const OpenCloseToken(
    this.type,
  );

  OpenCloseToken.open() : type = (OpenCloseType.open);
  OpenCloseToken.close() : type = (OpenCloseType.close);

  final OpenCloseType type;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OpenCloseToken &&
          runtimeType == other.runtimeType &&
          type == other.type;

  @override
  int get hashCode => type.hashCode;
}

enum OpenCloseType { open, close }

class BoldA extends OpenCloseToken {
  BoldA.open() : super.open();
  BoldA.close() : super.close();
}

class ItalicA extends OpenCloseToken {
  ItalicA.open() : super.open();
  ItalicA.close() : super.close();
}

class UnderlineA extends OpenCloseToken {
  UnderlineA.open() : super.open();
  UnderlineA.close() : super.close();
}

class StrikethroughA extends OpenCloseToken {
  StrikethroughA.open() : super.open();
  StrikethroughA.close() : super.close();
}
