import 'package:jaspr_class_scope/src/class_name.dart';

/// The locally scoped class names of one component.
///
/// ```dart
/// static const _class = _$heroScope;
/// static final _grid = _class('grid'); // 'grid-lz7xyh'
/// ```
///
/// A name made here cannot style another component's markup, and a raw
/// `'grid'` string elsewhere matches neither.
final class ClassScope {
  /// The scope of [name]'s class names, which all end with [suffix].
  ///
  /// Written by `jaspr_class_scope_builder`, never by hand.
  const ClassScope(this.name, this.suffix);

  /// The component this scope belongs to.
  final String name;

  /// What makes this scope's class names local to it.
  final String suffix;

  /// The class [local] of this scope's component.
  ClassName call(String local) => ClassName.scoped(local, this);

  @override
  String toString() => 'ClassScope($name)';
}
