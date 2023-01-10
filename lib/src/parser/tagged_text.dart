import 'package:flutter/foundation.dart';

/// Raw text together with applied active tags.
class TaggedText {
  const TaggedText(
    this.text, {
    this.tags = const {},
  });

  final String text;
  final Set<MarkupTag> tags;

  @override
  String toString() => 'TaggedText($text, $tags)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TaggedText && text == other.text && setEquals(tags, other.tags);

  @override
  int get hashCode => Object.hashAll([text, tags]);
}

/// A markup tag which decorates some piece of text.
class MarkupTag {
  const MarkupTag(this.name, [this.parameter]);

  final String name;
  final String? parameter;

  @override
  String toString() =>
      'MarkupTag($name${parameter != null ? ', $parameter' : ''})';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MarkupTag && name == other.name && parameter == other.parameter;

  @override
  int get hashCode => Object.hashAll([name, parameter]);
}
