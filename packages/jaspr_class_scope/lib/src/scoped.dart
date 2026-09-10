/// Marks a component whose class-name scope `jaspr_class_scope_builder`
/// generates, hashing it from the file the component is declared in.
///
/// ```dart
/// part 'hero.scopes.dart';
///
/// @scoped
/// class Hero extends StatelessComponent {
///   static const _class = _$heroScope;
/// }
/// ```
const scoped = Scoped();

/// The annotation behind [scoped].
final class Scoped {
  /// Marks the annotated component as one the builder writes a scope for.
  const Scoped();
}
