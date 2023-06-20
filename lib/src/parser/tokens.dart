import 'package:equatable/equatable.dart';

// TODO: store loc spans for tokens for better error reporting

/// Token represents a single entity result from tokenizing (lexing).
/// For example a tag like `[b]` or [/b] that identify start and end of tag with a name `'b'`.
sealed class Token {
  const Token();
}

class TagOpenToken extends Token with EquatableMixin {
  const TagOpenToken(this.name, [this.parameter]);

  final String name;
  final String? parameter;

  @override
  List<Object?> get props => [name, parameter];
}

class TagCloseToken extends Token with EquatableMixin {
  const TagCloseToken(this.name);

  final String name;

  @override
  List<Object?> get props => [name];
}

class TextToken extends Token with EquatableMixin {
  const TextToken(this.content);

  final String content;

  @override
  List<Object?> get props => [content];
}
