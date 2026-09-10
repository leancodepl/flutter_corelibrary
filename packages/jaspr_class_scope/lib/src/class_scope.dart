import 'package:jaspr_class_scope/src/class_name.dart';
import 'package:jaspr_class_scope/src/suffix.dart';
import 'package:meta/meta.dart';

/// Makes the CSS class names of one component, scoped to it.
///
/// Jaspr collects every `@css` getter into one global stylesheet and scopes
/// nothing, so this does at build time what CSS modules do: a component
/// declares one scope and makes its classes from it.
///
/// ```dart
/// class Hero extends StatelessComponent {
///   static const _class = ClassScope('Hero');
///   static final _grid = _class('grid');
///
///   @css
///   static List<StyleRule> get styles => [
///     css(_grid.selector).styles(display: Display.grid),
///   ];
///
///   @override
///   Iterable<Component> build(BuildContext context) sync* {
///     yield div(classes: _grid.name, []);
///   }
/// }
/// ```
///
/// `_grid` renders as `grid-<suffix>`, the suffix a short hash of the scope's
/// [name]. Two components can both call something `grid` and never meet in the
/// stylesheet, and a raw `'grid'` string elsewhere matches nothing. Selectors
/// ([ClassName.selector]) and `classes:` attributes ([ClassName.name]) are
/// spelled from the constant, so the suffix is never written by hand. Two
/// scopes that would hash alike throw the first time either one renders, so a
/// collision cannot slip through unnoticed.
///
/// Classes that another file knows by name — the ones a script looks up, or a
/// hand-written stylesheet styles — are not scoped: declare those with
/// [ClassName.shared].
final class ClassScope {
  /// A scope with the given [name], hashed as written.
  ///
  /// The name is the scope's whole identity, so two scopes spelling the same
  /// name are one scope: keep them unique across the project, or name them
  /// after the type with [ClassScope.ofType], which tells two classes of the
  /// same name apart.
  const ClassScope(this.name) : _owner = name, _suffix = null;

  /// A scope named after [type], so that renaming the component renames its
  /// scope.
  ///
  /// The name comes from `Type.toString()`, which drops the library the class
  /// lives in and which a minifying compiler is free to rewrite: for a
  /// component whose classes are rendered both on the server and by minified
  /// client code, spell the name out with [ClassScope.new] instead, so that
  /// both sides spell the same suffix.
  ///
  /// Two classes of the same name in different libraries hash alike; that is a
  /// collision and [suffix] throws on it, rather than quietly handing both
  /// components one namespace.
  ClassScope.ofType(Type type)
    : name = type.toString(),
      _owner = type,
      _suffix = null;

  /// A scope whose [suffix] was computed at build time, from the file the
  /// component is declared in.
  ///
  /// Written by `jaspr_class_scope_builder` for a component annotated with
  /// `@scoped`, never by hand: the builder is what knows where a class lives,
  /// which is what keeps two components of the same name apart.
  const ClassScope.literal(this.name, String suffix)
    : _owner = '$name#$suffix',
      _suffix = suffix;

  /// What this scope hashes.
  final String name;

  /// What this scope is: the type it was made for, or its literal name. Two
  /// scopes with the same [name] but different owners are two namespaces
  /// fighting over one suffix.
  final Object _owner;

  /// The build-time suffix, when this scope came from the builder.
  final String? _suffix;

  /// Five base-36 digits of an FNV-1a hash of [name]: the same on every
  /// platform, machine and version of this package, and short enough to read
  /// in the inspector.
  ///
  /// Throws a [StateError] when another scope already took this suffix, which
  /// means the two would share a namespace.
  String get suffix {
    final suffix = _suffix ?? classScopeSuffix(name);

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

    return suffix;
  }

  /// The class [local] of this scope's component.
  ClassName call(String local) => ClassName.scoped(local, this);

  @override
  String toString() => 'ClassScope($name)';

  /// The owner each handed-out suffix belongs to, so that a second scope
  /// hashing to it fails instead of silently sharing the namespace.
  static final Map<String, Object> _owners = {};

  /// Forgets which suffixes have been handed out.
  ///
  /// Only useful in tests that deliberately provoke a collision — the registry
  /// outlives them otherwise.
  @visibleForTesting
  static void resetRegistry() => _owners.clear();
}
