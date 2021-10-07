# leancode_lint

[![leancode_lint pub.dev badge][pub-badge]][pub-badge-link]

Lint rules used internally in LeanCode projects.

## Usage

Add `leancode_lint` as a normal dependency to access the `unawaited` function when using dart version lower than 2.14.

```yaml
dependencies:
  leancode_lint: ^1.0.0
```

### Apps

Add `include: package:leancode_lint/analysis_options.yaml` to `analysis_options.yaml` in your project.
If necessary you can exclude some files from analysis.

```dart
include: package:leancode_lint/analysis_options.yaml

# Optional
analyzer:
  exclude:
    - '**/*.g.dart'
```

### Packages

For packages add `include: package:leancode_lint/analysis_options.yaml` to `analysis_options.yaml`.

```dart
include: package:leancode_lint/analysis_options_package.yaml

# Optional
analyzer:
  exclude:
    - '**/*.g.dart'
```

[pub-badge]: https://img.shields.io/pub/v/leancode_lint
[pub-badge-link]: https://pub.dev/packages/leancode_lint
