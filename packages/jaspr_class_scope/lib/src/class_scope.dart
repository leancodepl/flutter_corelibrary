import 'package:jaspr_class_scope/src/class_name.dart';

/// The CSS class names of one component, scoped to it.
///
/// Jaspr's `@css` getters all land in one global stylesheet, so this does what
/// CSS modules do: a component declares one scope and makes its classes from
/// it, each rendering as `<local>-<suffix>`.
///
/// ```dart
/// static const _class = _$heroScope;
/// static final _grid = _class('grid'); // 'grid-iur6ms'
/// ```
///
/// Two components can then both call something `grid` without meeting in the
/// stylesheet, while a raw `'grid'` string elsewhere matches neither.
///
/// Classes another file knows by name are not scoped — declare those with
/// [ClassName.shared].
final class ClassScope {
  /// A scope for the component [name], whose classes end with [suffix].
  ///
  /// Written by `jaspr_class_scope_builder` for a component annotated with
  /// `@scopedCss`, never by hand: the builder hashes where the component is
  /// declared, which is what keeps two components of the same name apart.
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
