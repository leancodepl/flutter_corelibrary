// One component's classes, spelled from one scope. The Jaspr parts — `@css`,
// `css()`, `div()` — are left out so that the example stays dependency-free.

// The example prints what the component would render.
// ignore_for_file: avoid_print

import 'package:jaspr_class_scope/jaspr_class_scope.dart';

class Hero {
  static const _class = ClassScope('Hero');

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
  print(Hero.styles); // .grid-174ao > .title-174ao
  print(Hero.gridClasses); // grid-174ao
  print(copyButton.name); // js-copy
}
