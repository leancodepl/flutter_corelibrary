# jaspr_class_scope

[![jaspr_class_scope pub.dev badge][pub-badge]][pub-badge-link]
[![jaspr_class_scope continuous integration badge][build-badge]][build-badge-link]

Scoped CSS class names for [Jaspr] components, the way CSS modules do it. Jaspr
collects every `@css` getter into one global stylesheet and [scopes
nothing][jaspr-css], so two components that both style `.grid` style each other.
Here a component declares one scope, makes its classes from it, and each renders
with a short hash appended.

## Usage

```shell
dart pub add jaspr_class_scope
```

```dart
class Hero extends StatelessComponent {
  static const _class = ClassScope('Hero');

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

renders `<div class="grid-174ao"><h1 class="title-174ao">Hero</h1></div>`.
Another component's `_class('grid')` renders as `grid-f1teh`, so the two never
meet, and a raw `'grid'` string elsewhere matches neither. The `classes:`
attribute (`.name`) and the selector (`.selector`) come from the same constant,
so a rename cannot leave one behind.

## Naming a scope

A scope's name is its whole identity, so it has to be unique across the project.
`ClassScope.ofType(Hero)` names it after the component's type instead, which
survives a rename but reaches the page through `Type.toString()` — a minifying
compiler may rewrite it, and it drops the library, so two `Card` classes hash
alike and throw.

[`jaspr_class_scope_builder`][builder] takes that question away: it hashes the
*file* a component is declared in, so two same-named components are different
scopes by construction.

```dart
part 'hero.scopes.dart';

@scopedCss
class Hero extends StatelessComponent {
  static const _class = _$heroScope; // ClassScope.literal('Hero', '16rv7')
}
```

## Classes another file knows by name

A class a script looks up or a hand-written stylesheet styles is a contract with
that file, so it renders as written:

```dart
static const copyButton = ClassName.shared('js-copy');
```

## Two classes on one element

```dart
final primary = _class('button') + _class('primary');

primary.name; // 'button-174ao primary-174ao'
primary.selector; // '.button-174ao.primary-174ao'
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
