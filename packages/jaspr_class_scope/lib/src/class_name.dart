import 'package:jaspr_class_scope/src/class_scope.dart';

/// A CSS class name: made by a [ClassScope] for the component that owns it, or
/// [ClassName.shared] for a class that another file knows by name, which
/// renders as written.
///
/// Both the `classes:` attribute ([name]) and the selector ([selector]) are
/// spelled from the same constant, so the two cannot drift apart.
final class ClassName {
  /// A class rendered as written, because something outside the component —
  /// a script, a hand-written stylesheet, another package — knows it by the
  /// given [name].
  const ClassName.shared(String name)
    : _local = name,
      _scope = null,
      _and = null;

  /// The class [local] of [scope]'s component.
  ///
  /// Usually spelled by calling the scope itself: `_class('grid')`.
  const ClassName.scoped(String local, ClassScope scope)
    : _local = local,
      _scope = scope,
      _and = null;

  const ClassName._(this._local, this._scope, this._and);

  final String _local;
  final ClassScope? _scope;
  final ClassName? _and;

  /// The class as it appears in the page: the `classes:` value. For a
  /// combination of two classes, `a b`.
  String get name => _parts.join(' ');

  /// This class in a selector: `.name`. For a combination, `.a.b`: an element
  /// that carries both.
  String get selector => '.${_parts.join('.')}';

  List<String> get _parts => [
    switch (_scope) {
      null => _local,
      final scope => '$_local-${scope.suffix}',
    },
    ...?_and?._parts,
  ];

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
