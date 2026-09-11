import 'package:jaspr_class_scope/src/class_name.dart';

/// The CSS class names of one component, each rendering as `<local>-<suffix>`.
///
/// ```dart
/// static const _class = _$heroScope;
/// static final _grid = _class('grid'); // 'grid-lz7xyh'
/// ```
///
/// Two components can then both call something `grid` without their styles
/// reaching each other.
final class ClassScope {
  /// A scope for the component [name], whose classes end with [suffix].
  ///
  /// Written by `jaspr_class_scope_builder`, never by hand.
  const ClassScope(this.name, this.suffix);

  /// The component this scope belongs to.
  final String name;

  /// The six base-36 digits this scope's classes end with.
  final String suffix;

  /// The class [local] of this scope's component.
  ClassName call(String local) => ClassName.scoped(local, this);

  @override
  String toString() => 'ClassScope($name)';
}
