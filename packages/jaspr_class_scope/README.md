# jaspr_class_scope

[![jaspr_class_scope pub.dev badge][pub-badge]][pub-badge-link]
[![][build-badge]][build-badge-link]

Scoped CSS class names for [Jaspr] components, the way CSS modules do it.

Jaspr collects every `@css` getter into one global stylesheet and
[scopes nothing][jaspr-css] — two components that both style `.grid` style each
other. This package does at build time what CSS modules do: a component
declares one scope, makes its classes from it, and each renders with a short
hash of the scope's name appended.

```dart
class Hero extends StatelessComponent {
  static const _class = ClassScope('Hero');

  static final _grid = _class('grid');
  static final _title = _class('title');

  @css
  static List<StyleRule> get styles => [
    css(_grid.selector, [
      css('&').styles(display: Display.grid, gap: Gap.all(2.rem)),
      css(_title.selector).styles(fontSize: 3.rem),
    ]),
  ];

  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield div(classes: _grid.name, [
      h1(classes: _title.name, [text('Hero')]),
    ]);
  }
}
```

renders

```html
<div class="grid-174ao"><h1 class="title-174ao">Hero</h1></div>
```

Another component's `_class('grid')` renders as `grid-f1teh`, so the two never
meet; a raw `'grid'` string elsewhere matches neither.

## What you get

- **One owner per class.** A class exists only where its scope is declared, so
  a name can be reused freely across components.
- **One spelling.** The `classes:` attribute (`.name`) and the selector
  (`.selector`) come from the same constant, so a rename cannot leave one
  behind.
- **A stable suffix.** Five base-36 digits of an FNV-1a hash of the scope's
  name — the same on the VM and on the web, on every machine, and across
  versions of this package, so server-rendered and client-rendered markup
  agree and the diff of a rebuild stays empty.
- **A loud collision.** Two scopes that would hash alike throw a `StateError`
  the first time either one renders, instead of silently sharing a namespace.
- **No dependency on Jaspr** — it is plain Dart making strings, so it works
  with any way of writing CSS, and Jaspr's own `css()`/`classes:` take the
  strings as they are.

## Usage

Add the package:

```sh
dart pub add jaspr_class_scope
```

### Scoping to a component

```dart
static const _class = ClassScope('Hero');
static final _grid = _class('grid');
```

`ClassScope.ofType(Hero)` names the scope after the component's type instead, so
that renaming the component renames its scope. The name then reaches the page
through `Type.toString()`, which a minifying compiler may rewrite — for a
component whose classes are rendered both on the server and by minified client
code, spell the name out, so that both sides spell the same suffix.

### Classes somebody else knows by name

A class that a script looks up, a hand-written stylesheet styles, or another
package renders is a contract with that file: declare it shared and it renders
as written.

```dart
static const copyButton = ClassName.shared('js-copy');
```

### Two classes on one element

`+` puts both on the same element; the selector then matches an element
carrying both.

```dart
final primary = _class('button') + _class('primary');

primary.name; // 'button-174ao primary-174ao'
primary.selector; // '.button-174ao.primary-174ao'
```

### Variants

A variant can carry its class before scoping, and the component that renders it
does the scoping:

```dart
enum ButtonVariant {
  primary('primary'),
  ghost('ghost');

  const ButtonVariant(this.local);

  final String local;
}

class Button extends StatelessComponent {
  static const _class = ClassScope('Button');

  static ClassName classOf(ButtonVariant variant) => _class(variant.local);
}
```

[Jaspr]: https://jaspr.site
[jaspr-css]: https://docs.jaspr.site/api/utils/at_css
[pub-badge]: https://img.shields.io/pub/v/jaspr_class_scope
[pub-badge-link]: https://pub.dev/packages/jaspr_class_scope
[build-badge]: https://img.shields.io/github/actions/workflow/status/leancodepl/flutter_corelibrary/jaspr_class_scope-test.yml?branch=master
[build-badge-link]: https://github.com/leancodepl/flutter_corelibrary/actions/workflows/jaspr_class_scope-test.yml
