import 'package:equatable/equatable.dart';

// TODO: store loc spans for tokens for better error reporting

/// Token represents a single entity result from tokenizing (lexing).
/// For example a tag like `[b]` or [/b] that identify start and end of tag with a name `'b'`.
sealed class Token {
  const Token();

  String get token;
}

class TagOpenToken extends Token with EquatableMixin {
  const TagOpenToken(this.name, [this.parameter]);

  final String name;
  final String? parameter;

  @override
  List<Object?> get props => [name, parameter];

  @override
  String get token {
    if (parameter != null) {
      return '[$name="$parameter"]';
    } else {
      return '[$name]';
    }
  }
}

class TagCloseToken extends Token with EquatableMixin {
  const TagCloseToken(this.name);

  final String name;

  @override
  List<Object?> get props => [name];

  @override
  String get token => '[/$name]';
}

class TextToken extends Token with EquatableMixin {
  const TextToken(this.content);

  final String content;

  @override
  List<Object?> get props => [content];

  @override
  String get token => content;
}
