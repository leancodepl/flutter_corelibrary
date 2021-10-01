# leancode_lint

[![leancode_lint pub.dev badge][pub-badge]][pub-badge-link]

Lint rules used internally in LeanCode projects.

## Usage

Add `leancode_lint` as normal dependency to access `unawaited` function.

```yaml
dependencies:
  leancode_lint: ^1.0.0
```

### Apps

Include rules in `analysis_options.yaml` of your project.
If necessary you can exclude some files from analysis.

```dart
include: package:leancode_lint/analysis_options.yaml

# Optional
analyzer:
  exclude:
    - "**/*.g.dart"
```

### Packages

For packages include `analysis_options_package.yaml` instead.

```dart
include: package:leancode_lint/analysis_options_package.yaml

# Optional
analyzer:
  exclude:
    - "**/*.g.dart"
```

[pub-badge]: https://img.shields.io/pub/v/leancode_lint
[pub-badge-link]: https://pub.dev/packages/leancode_lint
