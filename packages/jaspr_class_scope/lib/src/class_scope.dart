import 'package:jaspr_class_scope/src/class_name.dart';
import 'package:jaspr_class_scope/src/suffix.dart';
import 'package:meta/meta.dart';

/// Makes the CSS class names of one component, scoped to it.
///
/// Jaspr's `@css` getters all land in one global stylesheet, so this does what
/// CSS modules do: a component declares one scope and makes its classes from
/// it, each rendering as `<local>-<suffix>`.
///
/// ```dart
/// static const _class = ClassScope('Hero');
/// static final _grid = _class('grid'); // 'grid-174ao'
/// ```
///
/// Two components can then both call something `grid` without meeting in the
/// stylesheet, while a raw `'grid'` string elsewhere matches neither.
///
/// Classes another file knows by name are not scoped — declare those with
/// [ClassName.shared].
final class ClassScope {
  /// A scope with the given [name], hashed as written.
  ///
  /// The name is the scope's whole identity: two scopes spelling the same name
  /// are one scope, so keep them unique across the project.
  const ClassScope(this.name) : _owner = name, _suffix = null;

  /// A scope named after [type], so that renaming the component renames it.
  ///
  /// The name comes from `Type.toString()`, which a minifying compiler may
  /// rewrite and which drops the library, so two classes of the same name hash
  /// alike — a collision [suffix] throws on.
  ClassScope.ofType(Type type)
    : name = type.toString(),
      _owner = type,
      _suffix = null;

  /// A scope whose [suffix] was hashed at build time from the file the
  /// component is declared in.
  ///
  /// Written by `jaspr_class_scope_builder` for a component annotated with
  /// `@scopedCss`, never by hand.
  const ClassScope.literal(this.name, String suffix)
    : _owner = '$name#$suffix',
      _suffix = suffix;

  /// What this scope hashes.
  final String name;

  /// What this scope is: the type it was made for, or its literal name.
  final Object _owner;

  /// The build-time suffix, when this scope came from the builder.
  final String? _suffix;

  /// The five base-36 digits this scope's classes end with.
  ///
  /// In debug mode, taking a suffix another scope already holds throws a
  /// [StateError] instead of the two quietly sharing a namespace. The builder
  /// makes that check across the whole package at build time, and asserts are
  /// compiled out of a release build.
  String get suffix {
    final suffix = _suffix ?? classScopeSuffix(name);
    assert(_claim(suffix), 'unreachable: _claim only ever returns true');

    return suffix;
  }

  /// The class [local] of this scope's component.
  ClassName call(String local) => ClassName.scoped(local, this);

  @override
  String toString() => 'ClassScope($name)';

  /// Records that this scope holds [suffix], throwing when another one got
  /// there first. Always returns true, so that it can live in an [assert].
  bool _claim(String suffix) {
    final taken = _owners.putIfAbsent(suffix, () => _owner);
    if (taken != _owner) {
      throw StateError(
        '$taken' == name
            ? 'Two scopes are both named "$name" — two classes of that name, '
                'or a class and a literal — so they share "-$suffix"; name '
                'one of them explicitly.'
            : 'ClassScope("$name") and ClassScope("$taken") both scope to '
                '"-$suffix"; rename one of them.',
      );
    }

    return true;
  }

  static final Map<String, Object> _owners = {};

  /// Forgets which suffixes have been handed out. For tests that provoke a
  /// collision on purpose — the registry outlives them otherwise.
  @visibleForTesting
  static void resetRegistry() => _owners.clear();
}
