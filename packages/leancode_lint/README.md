# leancode_lint

[![leancode_lint pub.dev badge][pub-badge]][pub-badge-link]

Lint rules used internally in LeanCode projects.

## Installation

Add `leancode_lint` as a dev dependency.

```yaml
dev_dependencies:
  leancode_lint: ^1.3.1
```

## Usage

### App

Add `include: package:leancode_lint/analysis_options.yaml` to
`analysis_options.yaml` in your project. You might want to exclude some files
(e.g generated freezed models) from analysis.

```yaml
include: package:leancode_lint/analysis_options.yaml

# Optional
analyzer:
  exclude:
    - '**/*.g.dart'
    - '**/*.freezed.dart'
```

### Package

Add `include: package:leancode_lint/analysis_options_package.yaml` to
`analysis_options.yaml` in your project. It includes additional lints for
packages. You might want to exclude some files (e.g generated freezed models)
from analysis.

```yaml
include: package:leancode_lint/analysis_options_package.yaml

# Optional
analyzer:
  exclude:
    - '**/*.g.dart'
    - '**/*.freezed.dart'
```

[pub-badge]: https://img.shields.io/pub/v/leancode_lint
[pub-badge-link]: https://pub.dev/packages/leancode_lint
