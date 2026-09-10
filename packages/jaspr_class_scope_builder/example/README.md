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

`dart run build_runner build` writes `lib/components/hero.scopes.dart`, and
`_grid` renders as `grid-iur6ms`. A second `Hero`, in another file, gets a
different suffix — the hash covers where the class is declared, not its name.
See the [package readme](../README.md) for the generated file and the check
phase.
