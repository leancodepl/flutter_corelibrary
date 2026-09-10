# jaspr_class_scope_builder

[![jaspr_class_scope_builder pub.dev badge][pub-badge]][pub-badge-link]
[![][build-badge]][build-badge-link]

Build-time class-name scopes for [`jaspr_class_scope`][jaspr_class_scope].

Written by hand, a scope is only as unique as its name: two components called
`Card` in two libraries hash alike, because `Type.toString()` drops the library
a class lives in. This builder hashes the **asset** instead — the package and
path the class is declared in — so two components of the same name simply get
two suffixes, and nothing has to fail for them to stay apart. It is what CSS
modules do, where the hash covers the file path.

## Usage

```yaml
dependencies:
  jaspr_class_scope: ^0.1.0

dev_dependencies:
  build_runner: ^2.4.0
  jaspr_class_scope_builder: ^0.1.0
```

Annotate the component and add the part file:

```dart
import 'package:jaspr_class_scope/jaspr_class_scope.dart';

part 'hero.scopes.dart';

@scoped
class Hero extends StatelessComponent {
  static const _class = _$heroScope;

  static final _grid = _class('grid');
}
```

`dart run build_runner build` writes `hero.scopes.dart` next to it:

```dart
// GENERATED CODE - DO NOT MODIFY BY HAND
// Written by jaspr_class_scope_builder.

part of 'hero.dart';

/// The class-name scope of [Hero], hashed from
/// `site|lib/components/hero.dart#Hero`.
const _$heroScope = ClassScope.literal('Hero', '16rv7');
```

so `_grid` renders as `grid-16rv7`, and the same `Hero` under
`lib/marketing/` renders as `grid-1f3xc`.

The constant is named after the class: `Hero` gives `_$heroScope`, `CardGrid`
gives `_$cardGridScope`. A file with no `@scoped` classes produces no output.

## What it buys you

- **No name collisions, ever.** Two same-named components in different files
  are different scopes by construction, with no runtime check to trip over.
- **No `Type.toString()` in the page.** The name is read from the source at
  build time, so a minifying compiler cannot rewrite what the class renders,
  and server- and client-rendered markup agree.
- **No hashing at runtime.** The suffix is a `const` in the generated file, so
  it is visible in code review and costs nothing in the browser.

The suffix follows the file: moving or renaming `hero.dart` changes it, exactly
as it does for CSS modules. Only the generated stylesheet and markup depend on
it, so nothing else notices — unless a class name is a contract with another
file, and those are declared with `ClassName.shared` and never scoped anyway.

[jaspr_class_scope]: https://pub.dev/packages/jaspr_class_scope
[pub-badge]: https://img.shields.io/pub/v/jaspr_class_scope_builder
[pub-badge-link]: https://pub.dev/packages/jaspr_class_scope_builder
[build-badge]: https://img.shields.io/github/actions/workflow/status/leancodepl/flutter_corelibrary/jaspr_class_scope_builder-test.yml?branch=master
[build-badge-link]: https://github.com/leancodepl/flutter_corelibrary/actions/workflows/jaspr_class_scope_builder-test.yml
