# leancode_lint

[![leancode_lint pub.dev badge][pub-badge]][pub-badge-link]

Lint rules used internally in LeanCode projects.

## Installation

Add `leancode_lint` as a dev dependency.

```sh
dart pub add leancode_lint --dev
```

## Usage

### App

Add `include: package:leancode_lint/analysis_options.yaml` to
`analysis_options.yaml` in your project. You might want to exclude some files
(e.g generated json serializable) from analysis.

```yaml
include: package:leancode_lint/analysis_options.yaml

# Optional
analyzer:
  exclude:
    - '**/*.g.dart'
```

### Package

Add `include: package:leancode_lint/analysis_options_package.yaml` to
`analysis_options.yaml` in your project. It includes additional lints for
packages. You might want to exclude some files (e.g generated json serializable)
from analysis.

```yaml
include: package:leancode_lint/analysis_options_package.yaml

# Optional
analyzer:
  exclude:
    - '**/*.g.dart'
```

[pub-badge]: https://img.shields.io/pub/v/leancode_lint
[pub-badge-link]: https://pub.dev/packages/leancode_lint
