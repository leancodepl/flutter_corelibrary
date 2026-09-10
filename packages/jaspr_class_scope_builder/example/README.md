# Example

```dart
// lib/components/hero.dart
import 'package:jaspr_class_scope/jaspr_class_scope.dart';

part 'hero.scopes.dart';

@scopedCss
class Hero extends StatelessComponent {
  static const _class = _$heroScope;

  static final _grid = _class('grid');

  @css
  static List<StyleRule> get styles => [
    css(_grid.selector).styles(display: Display.grid),
  ];

  @override
  Component build(BuildContext context) => div(classes: _grid.name, []);
}
```

`dart run build_runner build` writes the scope next to it, and `_grid` renders
as `grid-lz7xyh`. See the [package readme](../README.md).
