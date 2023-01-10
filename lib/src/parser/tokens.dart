import 'package:freezed_annotation/freezed_annotation.dart';

part 'tokens.freezed.dart';

// TODO: store loc spans for tokens for better error reporting

/// Token represents a single entity result from tokenizing (lexing).
/// For example a tag like `[b]` or [/b] that identify start and end of tag with a name `'b'`.
@freezed
class Token with _$Token {
  const factory Token.tagOpen(String name) = _TokenTagOpen;
  const factory Token.tagClose(String name) = _TokenTagClose;
  const factory Token.text(String content) = _TokenTagText;
}
