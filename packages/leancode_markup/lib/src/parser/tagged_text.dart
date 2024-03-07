import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

/// Raw text together with applied active tags.
class TaggedText with EquatableMixin {
  TaggedText(
    this.text, {
    this.tags = const [],
  });

  final String text;
  final List<MarkupTag> tags;

  @override
  String toString() => 'TaggedText($text, $tags)';

  @override
  List<Object?> get props => [text, tags];
}

/// A markup tag which decorates some piece of text.
@immutable
class MarkupTag with EquatableMixin {
  const MarkupTag(this.name, [this.parameter]);

  final String name;
  final String? parameter;

  @override
  String toString() =>
      'MarkupTag($name${parameter != null ? ', $parameter' : ''})';

  @override
  List<Object?> get props => [name, parameter];
}
