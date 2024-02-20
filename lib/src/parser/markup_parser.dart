import 'package:leancode_markup/src/parser/lexer.dart';
import 'package:leancode_markup/src/parser/tagged_text.dart';
import 'package:leancode_markup/src/parser/tokens.dart';
import 'package:meta/meta.dart';

Iterable<TaggedText> parseMarkup(
  String markup, {
  ParsingAloneTagTactic tactic = ParsingAloneTagTactic.hide,
}) {
  final tokens = lexer.parse(markup).value;
  final cleanTokens = cleanUpTokens(tokens, markup, tactic: tactic);

  return parseTokens(cleanTokens, markup, tactic: tactic);
}

/// Iterate through tokens, to verify, if all open and close tokens,
/// have matching pair.
/// The result should be different based on ParsingAloneTagTactic. It could
/// - show invalid tokens as text,
/// - hide invalid tokens,
/// - throw Exception
@internal
Tokens cleanUpTokens(
  Tokens tokens,
  String source, {
  ParsingAloneTagTactic tactic = ParsingAloneTagTactic.show,
}) {
  final openingTokens = <TagOpenToken>[];
  final invalidTokens = <Token>[];

  // Iterate through tags to verify if all have matching pair
  for (final token in tokens) {
    switch (token) {
      case TagOpenToken():
        openingTokens.add(token);
      case TagCloseToken(:final name):
        if (openingTokens.isEmpty) {
          invalidTokens.add(token);
        } else if (openingTokens.last.name != name) {
          final lastIndex = openingTokens
              .lastIndexWhere((openingToken) => openingToken.name == name);

          if (lastIndex == -1) {
            /// If there's no matching opening token, add closing token to invalid tokens
            invalidTokens.add(token);
          } else {
            /// If there's matching opening token, add tokens that are after it,
            /// on list to invalid tokens
            invalidTokens.addAll(openingTokens.sublist(lastIndex + 1));

            /// Remove from openingTokens invalid tokens and one valid,
            /// matching to closing token
            openingTokens.removeRange(
              lastIndex,
              openingTokens.length,
            );
          }
        } else {
          openingTokens.removeLast();
        }
      case TextToken():
    }
  }

  /// Add remaining opening tokens as invalid
  invalidTokens.addAll(openingTokens);

  /// Modify list based on tactic
  switch (tactic) {
    case ParsingAloneTagTactic.hide:
      return tokens.where((e) => !invalidTokens.contains(e)).toList();
    case ParsingAloneTagTactic.show:
      return tokens
          .map((e) => invalidTokens.contains(e) ? TextToken(e.token) : e)
          .toList();
    case ParsingAloneTagTactic.throwException:
      throw MarkupParsingException('Something to throw', source);
  }
}

/// Parses tokens into tagged texts.
/// Assumes [tokens] were constructed from [source] with [lexer].
@internal
Iterable<TaggedText> parseTokens(
  Tokens tokens,
  String source, {
  ParsingAloneTagTactic tactic = ParsingAloneTagTactic.hide,
}) sync* {
  // stack with tag names
  final tagStack = <MarkupTag>[];

  for (final token in tokens) {
    switch (token) {
      case TagOpenToken(:final name, :final parameter):
        tagStack.add(MarkupTag(name, parameter));
      case TagCloseToken():
        tagStack.removeLast();
      case TextToken(:final content):
        yield TaggedText(
          content,
          tags: [...tagStack],
        );
    }
  }
}

class MarkupParsingException extends FormatException {
  const MarkupParsingException(super.message, super.source);

  @override
  String toString() {
    return 'MarkupParsingException: ${super.toString()}';
  }
}

/// Tactic for handling left alone opening and closing tags during parsing.
enum ParsingAloneTagTactic {
  hide,
  show,
  throwException,
}
