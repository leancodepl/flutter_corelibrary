/// Marks a component whose scope `jaspr_class_scope_builder` writes.
///
/// ```dart
/// part 'hero.scopes.dart';
///
/// @scopedCss
/// class Hero {
///   static const _class = _$HeroScope;
/// }
/// ```
const scopedCss = ScopedCss();

/// The annotation behind [scopedCss].
final class ScopedCss {
  /// See [scopedCss].
  const ScopedCss();
}
