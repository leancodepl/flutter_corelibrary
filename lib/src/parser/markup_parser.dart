import 'package:leancode_markup/leancode_markup.dart';
import 'package:leancode_markup/src/parser/lexer.dart';
import 'package:leancode_markup/src/parser/tokens.dart';
import 'package:logging/logging.dart';
import 'package:meta/meta.dart';

Iterable<TaggedText> parseMarkup(String markup, {Logger? logger}) {
  final tokens = lexer.parse(markup).value;
  final cleanTokens = cleanUpTokens(tokens, markup, logger: logger);

  return parseTokens(cleanTokens, markup);
}

/// Transform [tokens] into a balanced list of open and close tokens.
/// Shows invalid tokens as text.
@internal
Tokens cleanUpTokens(Tokens tokens, String source, {Logger? logger}) {
  final openingTokens = <(TagOpenToken, int)>[];
  final invalidTokens = <(Token, int)>[];

  // Iterate through tags to verify if all have matching pair
  for (final (index, token) in tokens.indexed) {
    switch (token) {
      case TagOpenToken():
        openingTokens.add((token, index));
      case TagCloseToken(:final name):
        if (openingTokens.isEmpty) {
          invalidTokens.add((token, index));
        } else if (openingTokens.last.$1.name != name) {
          final lastIndex = openingTokens
              .lastIndexWhere((openingToken) => openingToken.$1.name == name);

          if (lastIndex == -1) {
            // If there's no matching opening token, add closing token to invalid tokens
            invalidTokens.add((token, index));
          } else {
            // If there's matching opening token, add tokens that are after it,
            // on list to invalid tokens
            invalidTokens.addAll(openingTokens.sublist(lastIndex + 1));

            // Remove from openingTokens invalid tokens and one valid,
            // matching to closing token
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

  final toReturn = <Token>[];

  /// Modify list
  for (final (index, token) in tokens.indexed) {
    if (invalidTokens.contains((token, index))) {
      logger?.warning('Invalid token ${token.token}');
      toReturn.add(TextToken(token.token));
    } else {
      toReturn.add(token);
    }
  }

  return toReturn;
}

/// Parses tokens into tagged texts.
/// Assumes [tokens] were constructed from [source] with [lexer].
@internal
Iterable<TaggedText> parseTokens(Tokens tokens, String source) sync* {
  // stack with tag names
  final tagStack = <MarkupTag>[];

  for (final token in tokens) {
    switch (token) {
      case TagOpenToken(:final name, :final parameter):
        tagStack.add(MarkupTag(name, parameter));
      case TagCloseToken(:final name):
        if (tagStack.isEmpty || tagStack.last.name != name) {
          throw MarkupParsingException(
            'Found a closing tag without a matching opening one.',
            source,
          );
        } else {
          tagStack.removeLast();
        }
      case TextToken(:final content):
        yield TaggedText(
          content,
          tags: [...tagStack],
        );
    }
  }

  if (tagStack.isNotEmpty) {
    throw MarkupParsingException(
      'Not all opening tags have a matching closing one.',
      source,
    );
  }
}

class MarkupParsingException extends FormatException {
  const MarkupParsingException(super.message, super.source);

  @override
  String toString() {
    return 'MarkupParsingException: ${super.toString()}';
  }
}
