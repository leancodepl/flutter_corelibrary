import 'package:jaspr_class_scope/src/class_scope.dart';

/// A class name, spelled once for both the `classes:` attribute ([name]) and
/// the selector ([selector]) so the two cannot drift apart.
final class ClassName {
  /// A class rendered as written, because something outside the component
  /// knows it by [name].
  const ClassName.shared(this._local) : _scope = null, _and = null;

  /// A class local to the component of a [ClassScope].
  const ClassName.scoped(this._local, this._scope) : _and = null;

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

  /// This class and [other] on the same element; just this class when
  /// [other] is null, so an optional class needs no special case.
  ClassName operator +(ClassName? other) => switch (other) {
    null => this,
    final other => switch (_and) {
      null => ClassName._(_local, _scope, other),
      final and => ClassName._(_local, _scope, and + other),
    },
  };

  @override
  bool operator ==(Object other) => other is ClassName && other.name == name;

  @override
  int get hashCode => name.hashCode;

  @override
  String toString() => name;
}

/// Lets an optional class start a sum too, not only end one.
extension NullableClassName on ClassName? {
  /// This class and [other] on the same element, leaving out whichever is
  /// null; null only when both are.
  ///
  /// Dart has no overloading, so the sum is nullable even when [other] is
  /// not: a sum that begins with a class known to be there stays non-null.
  ClassName? operator +(ClassName? other) => switch (this) {
    null => other,
    final self => self + other,
  };
}
