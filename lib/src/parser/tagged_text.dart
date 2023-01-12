import 'dart:collection';

/// Raw text together with applied active tags.
class TaggedText {
  TaggedText(
    this.text, {
    LinkedHashMap<String, String?>? tags,
    // ignore: prefer_collection_literals
  }) : tags = tags ?? LinkedHashMap<String, String?>();

  final String text;

  /// tagName -> parameter
  final LinkedHashMap<String, String?> tags;

  @override
  String toString() => 'TaggedText($text, $tags)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TaggedText &&
          text == other.text &&
          _linkedHashMapEqual(tags, other.tags);

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

bool _linkedHashMapEqual<K, V>(LinkedHashMap<K, V> a, LinkedHashMap<K, V> b) {
  if (a.length != b.length) {
    return false;
  }
  if (identical(a, b)) {
    return true;
  }
  final iter1 = a.entries.iterator;
  final iter2 = b.entries.iterator;
  while (iter1.moveNext() && iter2.moveNext()) {
    if (iter1.current.key != iter2.current.key ||
        iter1.current.value != iter2.current.value) {
      return false;
    }
  }

  return true;
}
