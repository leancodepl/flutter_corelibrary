import 'package:flutter/foundation.dart';

/// Raw text together with applied active tags.
class TaggedText {
  const TaggedText(
    this.text, {
    this.tags = const {},
  });

  final String text;
  final Set<String> tags;

  @override
  String toString() => 'TaggedText($text, $tags)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TaggedText && text == other.text && setEquals(tags, other.tags);

  @override
  int get hashCode => Object.hashAll([text, tags]);
}
