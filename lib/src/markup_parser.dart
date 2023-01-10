import 'package:leancode_markup/src/lexer.dart';
import 'package:leancode_markup/src/text_with_attributes.dart';

class MarkupParser {
  List<TextWithAttributes> parse(List<Token> tokens) {
    final tokenMap = <OpenCloseToken, List<OpenCloseToken>>{};
    final result = <TextWithAttributes>[];

    for (final token in tokens) {
      if (token is OpenCloseToken) {
        if (token.isOpeningToken) {
          tokenMap.addTokenToTokenMap(token);
        } else if (token.isClosingToken) {
          tokenMap.removeTokenFromTokenMap(token);
        }
      }

      if (token is TextToken) {
        result.add(
          TextWithAttributes(
            text: token.text,
            attributes: tokenMap.getAttributesSet,
          ),
        );
      }
    }
    return result;
  }
}

extension TokenX on OpenCloseToken {
  bool get isOpeningToken => type == OpenCloseType.open;
  bool get isClosingToken => type == OpenCloseType.open;
}

extension TokenMapExt<T> on Map<T, List<T>> {
  void addTokenToTokenMap(T token) {
    if (this[token] != null) {
      this[token] = this[token]! + [token];
    } else {
      this[token] = [token];
    }
  }

  void removeTokenFromTokenMap(T token) {
    if (this[token] != null && this[token]!.isNotEmpty) {
      this[token] = List.from(this[token]!).removeLast();
    } else {
      throw (Exception('More closing $token tokens, than opening ones.'));
    }
  }
}

extension AttributeX on OpenCloseToken {
  Attribute? toAttribute() {
    if (this is UnderlineA) {
      return const Underline();
    } else if (this is ItalicA) {
      return const Italic();
    } else if (this is BoldA) {
      return const Bold();
    }
    return null;
  }
}

extension Attributes on Map<OpenCloseToken, List<OpenCloseToken>> {
  Set<Attribute> get getAttributesSet {
    final openCloseTokens = keys;
    Set<Attribute> attributesSet = {};
    for (var token in openCloseTokens) {
      final attr = token.toAttribute();
      if (attr != null) attributesSet.add(attr);
    }
    return attributesSet;
  }
}
