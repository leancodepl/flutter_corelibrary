# jaspr_class_scope_builder

[![jaspr_class_scope_builder pub.dev badge][pub-badge]][pub-badge-link]
[![jaspr_class_scope_builder continuous integration badge][build-badge]][build-badge-link]

Build-time generator for [jaspr_class_scope]: gives every Jaspr component
locally scoped CSS class names, so one component's styles cannot reach another.

## Usage

```yaml
dependencies:
  jaspr_class_scope: ^0.1.0

dev_dependencies:
  build_runner: ^2.4.0
  jaspr_class_scope_builder: ^0.1.0
```

```dart
import 'package:jaspr_class_scope/jaspr_class_scope.dart';

part 'hero.scopes.dart';

@scopedCss
class Hero extends StatelessComponent {
  static const _class = _$heroScope;

  static final _grid = _class('grid');
}
```

`dart run build_runner build` writes `hero.scopes.dart` next to it, holding
`Hero`'s scope. `_grid` then renders as `grid` with a suffix belonging to that
scope; the same class under `lib/marketing/` gets its own. Moving the file or
renaming the class changes the scope. `CardGrid` gives `_$cardGridScope`; a
file with no annotated classes produces no output.

## The check phase

Two components can end up with the same suffix, rarely. A second builder checks
for that once per package, so it fails the build instead of a page:

```
[SEVERE] jaspr_class_scope_builder:class_scope_check on $package$:
Hero (lib/marketing/hero.dart) and Hero (lib/components/hero.dart) both scope
to the same suffix. Rename or move one of them.
```

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
