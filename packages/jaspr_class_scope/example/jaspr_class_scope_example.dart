// One component's classes, spelled from one scope. The Jaspr parts — `@css`,
// `css()`, `div()` — are left out so that the example stays dependency-free.

// The example prints what the component would render.
// ignore_for_file: avoid_print

import 'package:jaspr_class_scope/jaspr_class_scope.dart';

/// What `jaspr_class_scope_builder` writes into `hero.scopes.dart` for a
/// component annotated with `@scopedCss`.
const _$heroScope = ClassScope('Hero', '6rv7vf');

class Hero {
  static const _class = _$heroScope;

  static final _grid = _class('grid');
  static final _title = _class('title');

  /// What a `@css` getter would style.
  static String get styles => '${_grid.selector} > ${_title.selector}';

  /// What `build` would render.
  static String get gridClasses => _grid.name;
}

/// A class the page's script looks up by name is not scoped.
const copyButton = ClassName.shared('js-copy');

void main() {
  print(Hero.styles); // .grid-6rv7vf > .title-6rv7vf
  print(Hero.gridClasses); // grid-6rv7vf
  print(copyButton.name); // js-copy
}
