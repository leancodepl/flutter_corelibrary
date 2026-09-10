/// Marks a component whose scope `jaspr_class_scope_builder` writes.
///
/// ```dart
/// part 'hero.scopes.dart';
///
/// @scopedCss
/// class Hero extends StatelessComponent {
///   static const _class = _$heroScope;
/// }
/// ```
const scopedCss = ScopedCss();

/// The annotation behind [scopedCss].
final class ScopedCss {
  /// Marks the annotated component as one the builder writes a scope for.
  const ScopedCss();
}
