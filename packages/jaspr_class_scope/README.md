# jaspr_class_scope

[![jaspr_class_scope pub.dev badge][pub-badge]][pub-badge-link]
[![jaspr_class_scope continuous integration badge][build-badge]][build-badge-link]

Scoped CSS class names for [Jaspr] components, the way CSS modules do it. Jaspr
collects every `@css` getter into one global stylesheet and [scopes
nothing][jaspr-css], so two components that both style `.grid` style each other.
Here a component declares one scope, makes its classes from it, and each renders
with a short hash appended.

The scope itself comes from [`jaspr_class_scope_builder`][builder], which hashes
the file a component is declared in — two components of the same name are
different scopes by construction.

## Usage

```shell
dart pub add jaspr_class_scope
dart pub add --dev jaspr_class_scope_builder build_runner
```

```dart
part 'hero.scopes.dart';

@scopedCss
class Hero extends StatelessComponent {
  static const _class = _$heroScope;

  static final _grid = _class('grid');
  static final _title = _class('title');

  @css
  static List<StyleRule> get styles => [
    css(_grid.selector).styles(display: Display.grid),
    css(_title.selector).styles(fontSize: 3.rem),
  ];

  @override
  Component build(BuildContext context) =>
      div(classes: _grid.name, [h1(classes: _title.name, [text('Hero')])]);
}
```

After `dart run build_runner build`, this renders
`<div class="grid-16rv7"><h1 class="title-16rv7">Hero</h1></div>`. Another
component's `_class('grid')` renders with its own suffix, so the two never meet,
and a raw `'grid'` string elsewhere matches neither. The `classes:` attribute
(`.name`) and the selector (`.selector`) come from the same constant, so a
rename cannot leave one behind.

## Classes another file knows by name

A class a script looks up or a hand-written stylesheet styles is a contract with
that file, so it renders as written:

```dart
static const copyButton = ClassName.shared('js-copy');
```

## Two classes on one element

```dart
final primary = _class('button') + _class('primary');

primary.name; // 'button-16rv7 primary-16rv7'
primary.selector; // '.button-16rv7.primary-16rv7'
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

[pub-badge]: https://img.shields.io/pub/v/jaspr_class_scope
[pub-badge-link]: https://pub.dev/packages/jaspr_class_scope
[build-badge]: https://img.shields.io/github/actions/workflow/status/leancodepl/flutter_corelibrary/jaspr_class_scope-test.yml?branch=master
[build-badge-link]: https://github.com/leancodepl/flutter_corelibrary/actions/workflows/jaspr_class_scope-test.yml
[builder]: https://pub.dev/packages/jaspr_class_scope_builder
[Jaspr]: https://jaspr.site
[jaspr-css]: https://docs.jaspr.site/api/utils/at_css
[leancode-landing]: https://leancode.co/?utm_source=github.com&utm_medium=referral&utm_campaign=jaspr-class-scope
[leancode-estimate]: https://leancode.co/get-estimate?utm_source=github.com&utm_medium=referral&utm_campaign=jaspr-class-scope
[leancode-packages]: https://pub.dev/packages?q=publisher%3Aleancode.co&sort=downloads
[patrol-landing]: https://patrol.leancode.co/?utm_source=github.com&utm_medium=referral&utm_campaign=jaspr-class-scope
