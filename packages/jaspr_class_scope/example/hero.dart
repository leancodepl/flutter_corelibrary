// A component, as a Jaspr app writes one. The Jaspr parts — `@css`, `css()`,
// `div()` — are left out so that the example stays dependency-free.

import 'package:jaspr_class_scope/jaspr_class_scope.dart';

part 'hero.scopes.dart';

@scopedCss
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
