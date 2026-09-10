import 'package:jaspr_class_scope/src/class_name.dart';
import 'package:meta/meta.dart';

/// The CSS class names of one component, scoped to it.
///
/// Jaspr's `@css` getters all land in one global stylesheet, so this does what
/// CSS modules do: a component declares one scope and makes its classes from
/// it, each rendering as `<local>-<suffix>`.
///
/// ```dart
/// static const _class = _$heroScope;
/// static final _grid = _class('grid'); // 'grid-16rv7'
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
  /// `@scopedCss`, never by hand: the builder hashes the file the component is
  /// declared in, which is what keeps two components of the same name apart.
  const ClassScope(this.name, String suffix) : _suffix = suffix;

  /// The component this scope belongs to.
  final String name;

  final String _suffix;

  /// The five base-36 digits this scope's classes end with.
  ///
  /// In debug mode, taking a suffix another scope already holds throws a
  /// [StateError] instead of the two quietly sharing a namespace. Within one
  /// package the builder catches that at build time; this also covers scopes
  /// coming from different packages. Asserts are compiled out of a release
  /// build.
  String get suffix {
    assert(_claim(), 'unreachable: _claim only ever returns true');

    return _suffix;
  }

  /// The class [local] of this scope's component.
  ClassName call(String local) => ClassName.scoped(local, this);

  @override
  String toString() => 'ClassScope($name)';

  /// Records that this scope holds its suffix, throwing when another one got
  /// there first. Always returns true, so that it can live in an [assert].
  bool _claim() {
    final taken = _owners.putIfAbsent(_suffix, () => name);
    if (taken != name) {
      throw StateError(
        '$name and $taken both scope to "-$_suffix"; move one of them, so '
        'that the file it is declared in hashes differently.',
      );
    }

    return true;
  }

  static final Map<String, String> _owners = {};

  /// Forgets which suffixes have been handed out. For tests that provoke a
  /// collision on purpose — the registry outlives them otherwise.
  @visibleForTesting
  static void resetRegistry() => _owners.clear();
}
