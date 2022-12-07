//Data structure that holds text + list of markdown attributes.
class TextWithAttributes {
  const TextWithAttributes({
    required this.text,
    this.attributes = const {},
  });

  final String text;
  final Set<Attribute> attributes;

  @override
  String toString() => 'text: $text, attributes: $attributes';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TextWithAttributes &&
          text == other.text &&
          attributes.symmetricDifference(other.attributes).isEmpty;

  @override
  int get hashCode => text.hashCode + attributes.hashCode;
}

abstract class Attribute {
  const Attribute();
}

class Italic extends Attribute {
  const Italic();
}

class Bold extends Attribute {
  const Bold();
}

class Underline extends Attribute {
  const Underline();
}

class Strikethrough extends Attribute {
  const Strikethrough();
}

class Link extends Attribute {
  Link(this.url);

  final String url;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Link && runtimeType == other.runtimeType && url == other.url;

  @override
  int get hashCode => url.hashCode;
}

extension SimExt<T> on Set<T> {
  Set<T> symmetricDifference(Set<T> other) =>
      difference(other).union(other.difference(this));
}
