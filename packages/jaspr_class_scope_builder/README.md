# jaspr_class_scope_builder

[![jaspr_class_scope_builder pub.dev badge][pub-badge]][pub-badge-link]
[![jaspr_class_scope_builder continuous integration badge][build-badge]][build-badge-link]

Build-time class-name scopes for [jaspr_class_scope]. A scope written by hand is
only as unique as its name; this builder hashes the file a component is declared
in, so two components of the same name are different scopes by construction —
what CSS modules do, where the hash covers the file path.

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

@scopedCss
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

so `_grid` renders as `grid-16rv7`, while the same `Hero` under `lib/marketing/`
renders as `grid-1f3xc`. The constant is named after the class: `CardGrid` gives
`_$cardGridScope`. A file with no annotated classes produces no output.

The suffix follows the file, so moving or renaming `hero.dart` changes it. Only
the generated stylesheet and markup depend on it; a class another file knows by
name is declared with `ClassName.shared` and never scoped.

## The check phase

A second builder runs once per package, after the scopes are written, and reads
them back. Five base-36 digits leave room for two unrelated files to hash alike,
rarely — when they do, the build fails instead of a page discovering it while
rendering:

```
[SEVERE] jaspr_class_scope_builder:class_scope_check on $package$:
Hero (lib/marketing/hero.scopes.dart) and Hero (lib/components/hero.scopes.dart)
both scope to "-16rv7". Rename or move one of them; the suffix is hashed from
the file a component is declared in.
```

`jaspr_class_scope`'s own check sits behind an `assert`, so a release build
carries neither it nor any hashing: the suffix is a `const`.

---

## 🛠️ Maintained by LeanCode
<div align="center">

  [<img src="https://leancodepublic.blob.core.windows.net/public/wide.png" alt="LeanCode Logo" height="100" />][leancode-landing]

</div>

This package is built with 💙 by **[LeanCode][leancode-landing]**.
We are **top-tier experts** focused on Flutter Enterprise solutions.

### Why LeanCode?

- **Creators of [Patrol][patrol-landing]** – the next-gen testing framework for Flutter.

- **Production-Ready** – We use this package in apps with millions of users.
- **Full-Cycle Product Development** – We take your product from scratch to long-term maintenance.

<div align="center">
  <br />

  **Need help with your Flutter project?**

  [**👉 Hire our team**][leancode-estimate]
  &nbsp;&nbsp;•&nbsp;&nbsp;
  [Check our other packages][leancode-packages]

</div>

[pub-badge]: https://img.shields.io/pub/v/jaspr_class_scope_builder
[pub-badge-link]: https://pub.dev/packages/jaspr_class_scope_builder
[build-badge]: https://img.shields.io/github/actions/workflow/status/leancodepl/flutter_corelibrary/jaspr_class_scope_builder-test.yml?branch=master
[build-badge-link]: https://github.com/leancodepl/flutter_corelibrary/actions/workflows/jaspr_class_scope_builder-test.yml
[jaspr_class_scope]: https://pub.dev/packages/jaspr_class_scope
[leancode-landing]: https://leancode.co/?utm_source=github.com&utm_medium=referral&utm_campaign=jaspr-class-scope-builder
[leancode-estimate]: https://leancode.co/get-estimate?utm_source=github.com&utm_medium=referral&utm_campaign=jaspr-class-scope-builder
[leancode-packages]: https://pub.dev/packages?q=publisher%3Aleancode.co&sort=downloads
[patrol-landing]: https://patrol.leancode.co/?utm_source=github.com&utm_medium=referral&utm_campaign=jaspr-class-scope-builder
