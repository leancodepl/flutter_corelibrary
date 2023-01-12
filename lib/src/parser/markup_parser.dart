import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:leancode_markup/src/parser/lexer.dart';
import 'package:leancode_markup/src/parser/tagged_text.dart';

Iterable<TaggedText> parseMarkup(String markup) {
  final tokens = lexer.parse(markup).value;

  return parseTokens(tokens, markup);
}

/// Parses tokens into tagged texts.
/// Assumes [tokens] were constructed from [source] with [lexer].
@visibleForTesting
Iterable<TaggedText> parseTokens(Tokens tokens, String source) sync* {
  // stack with tag names
  final tagStack = <MarkupTag>[];

  for (final token in tokens) {
    final content = token.when(
      tagOpen: (name, parameter) {
        tagStack.add(MarkupTag(name, parameter));
        return null;
      },
      tagClose: (name) {
        if (tagStack.isEmpty || tagStack.last.name != name) {
          throw MarkupParsingException(
            'Found a closing tag without a matching opening one.',
            source,
          );
        } else {
          tagStack.removeLast();
        }

        return null;
      },
      text: (content) => content,
    );

    if (content != null) {
      yield TaggedText(
        content,
        tags: Map.fromEntries(
          tagStack.map((e) => MapEntry(e.name, e.parameter)),
        ),
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
