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
  final balanced = tokens.toList();

  // Iterate through tags to verify if all have matching pair
  for (final (index, token) in tokens.indexed) {
    switch (token) {
      case TagOpenToken():
        openingTokens.add((token, index));
      case TagCloseToken(:final name):
        if (openingTokens.isEmpty) {
          balanced[index] = TextToken(token.token);
        } else if (openingTokens.last.$1.name != name) {
          final lastIndex = openingTokens
              .lastIndexWhere((openingToken) => openingToken.$1.name == name);

          if (lastIndex == -1) {
            // If there's no matching opening token, change closing token to TextToken
            balanced[index] = TextToken(token.token);
          } else {
            // If there's matching opening token, change tokens that are after it,
            // on list to TextTokens
            openingTokens.sublist(lastIndex + 1).forEach((element) {
              balanced[element.$2] = TextToken(element.$1.token);
            });

            // Remove from openingTokens invalid tokens and one valid token,
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

  /// Change remaining opening tokens to TextToken
  for (final element in openingTokens) {
    balanced[element.$2] = TextToken(element.$1.token);
  }

  return balanced;
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
