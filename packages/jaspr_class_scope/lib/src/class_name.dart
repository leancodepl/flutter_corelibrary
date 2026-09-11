import 'package:jaspr_class_scope/src/class_scope.dart';

/// A class name, spelled once for both the `classes:` attribute ([name]) and
/// the selector ([selector]) so the two cannot drift apart.
final class ClassName {
  /// A class rendered as written, because something outside the component
  /// knows it by [name].
  const ClassName.shared(String name)
    : _local = name,
      _scope = null,
      _and = null;

  /// The class [local] of [scope]'s component.
  const ClassName.scoped(String local, ClassScope scope)
    : _local = local,
      _scope = scope,
      _and = null;

  const ClassName._(this._local, this._scope, this._and);

  final String _local;
  final ClassScope? _scope;
  final ClassName? _and;

  /// The `classes:` value; `a b` for a combination.
  String get name => switch (_and) {
    null => _rendered,
    final and => '$_rendered ${and.name}',
  };

  /// The selector; `.a.b` for a combination, matching an element with both.
  String get selector => switch (_and) {
    null => '.$_rendered',
    final and => '.$_rendered${and.selector}',
  };

  String get _rendered => switch (_scope) {
    null => _local,
    final scope => '$_local-${scope.suffix}',
  };

  /// This class and [other] on the same element.
  ClassName operator +(ClassName other) => switch (_and) {
    null => ClassName._(_local, _scope, other),
    final and => ClassName._(_local, _scope, and + other),
  };

  @override
  bool operator ==(Object other) => other is ClassName && other.name == name;

  @override
  int get hashCode => name.hashCode;

  @override
  String toString() => name;
}
