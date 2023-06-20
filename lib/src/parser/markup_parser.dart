import 'package:leancode_markup/src/parser/lexer.dart';
import 'package:leancode_markup/src/parser/tagged_text.dart';
import 'package:leancode_markup/src/parser/tokens.dart';
import 'package:meta/meta.dart';

Iterable<TaggedText> parseMarkup(String markup) {
  final tokens = lexer.parse(markup).value;

  return parseTokens(tokens, markup);
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
