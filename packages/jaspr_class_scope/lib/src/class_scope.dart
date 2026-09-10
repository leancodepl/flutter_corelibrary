import 'package:jaspr_class_scope/src/class_name.dart';
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
  const ClassScope(this.name);

  /// A scope named after [type], so that renaming the component renames its
  /// scope.
  ///
  /// The name comes from `Type.toString()`, which a minifying compiler is free
  /// to rewrite: for a component whose classes are rendered both on the server
  /// and by minified client code, spell the name out with [ClassScope.new]
  /// instead, so that both sides spell the same suffix.
  ClassScope.ofType(Type type) : name = type.toString();

  /// What this scope hashes.
  final String name;

  /// Five base-36 digits of an FNV-1a hash of [name]: the same on every
  /// platform, machine and version of this package, and short enough to read
  /// in the inspector.
  ///
  /// Throws a [StateError] when another scope already took this suffix, which
  /// means the two would share a namespace.
  String get suffix {
    final digits = _hash(name).toRadixString(36);
    final suffix = digits.padLeft(5, '0').substring(0, 5);

    final taken = _names.putIfAbsent(suffix, () => name);
    if (taken != name) {
      throw StateError(
        'ClassScope("$name") and ClassScope("$taken") both scope to '
        '"-$suffix"; rename one of them.',
      );
    }

    return suffix;
  }

  /// The class [local] of this scope's component.
  ClassName call(String local) => ClassName.scoped(local, this);

  @override
  String toString() => 'ClassScope($name)';

  /// FNV-1a over the code units of [input], in 32 bits.
  ///
  /// The multiplication is done in halves so that no intermediate product
  /// exceeds 2^53: on the web an `int` is a double, and a plain `hash * prime`
  /// would round there but not on the VM, handing the same component two
  /// different suffixes.
  static int _hash(String input) {
    var hash = 0x811c9dc5;
    for (final unit in input.codeUnits) {
      hash ^= unit;
      final low = hash & 0xffff;
      final high = hash >> 16;
      hash =
          (low * 0x01000193 + ((high * 0x01000193 & 0xffff) << 16)) &
          0xffffffff;
    }
    return hash;
  }

  /// The name each handed-out suffix belongs to, so that a second scope
  /// hashing to it fails instead of silently sharing the namespace.
  static final Map<String, String> _names = {};

  /// Forgets which suffixes have been handed out.
  ///
  /// Only useful in tests that deliberately provoke a collision — the registry
  /// outlives them otherwise.
  @visibleForTesting
  static void resetRegistry() => _names.clear();
}
