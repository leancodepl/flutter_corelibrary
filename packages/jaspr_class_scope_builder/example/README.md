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
  Iterable<Component> build(BuildContext context) sync* {
    yield div(classes: _grid.name, []);
  }
}
```

`dart run build_runner build` writes `lib/components/hero.scopes.dart`:

```dart
// GENERATED CODE - DO NOT MODIFY BY HAND
// Written by jaspr_class_scope_builder.

part of 'hero.dart';

/// The class-name scope of [Hero], hashed from
/// `site|lib/components/hero.dart#Hero`.
const _$heroScope = ClassScope.literal('Hero', '16rv7');
```

and `_grid` renders as `grid-16rv7`. A second `Hero`, in another file, renders
as `grid-<a different suffix>` — the hash covers the file, not the class name.
