# leancode_lint

[![leancode_lint pub.dev badge][pub-badge]][pub-badge-link]

Lint rules used internally in LeanCode projects.

## Installation

1. Add `leancode_lint` as a dev dependency in your project `pubspec.yaml`.

```sh
dart pub add leancode_lint --dev
```

2. In your `analysis_options.dart` add `include: package:leancode_lint/analysis_options.yaml`. You might want to exclude some files
(e.g generated json serializable) from analysis.

4. Add `custom_lint` plugin for `analyzer` in `analysis_options.yaml`. You can customize them by adding `custom_lint` config 
with `rules` like in the example below.

5. Run `fvm flutter pub get` in your project main directory and restart your IDE. You're ready to go!
   
```yaml
include: package:leancode_lint/analysis_options.yaml

# Optional custom lints configuration
custom_lint:
  rules:
    - use_design_system_item:
      LftText:
        - instead_of: Text
          from_package: flutter
        - instead_of: RichText
          from_package: flutter
      LftScaffold:
        - instead_of: Scaffold
          from_package: flutter

analyzer:
  plugins:
    # Required for our custom lints support
    - custom_lint
  exclude:
    - '**/*.g.dart'
```

## Package development

Make sure you have added `custom_lint` plugin to `analysis_options.yaml` in package directory.

```yaml
include: lib/analysis_options_package.yaml

analyzer:
  plugins:
    - custom_lint
```

Within this package, you can define our own lints, assists and quick fixes. See [this](https://leancode.atlassian.net/wiki/spaces/LEAN/pages/2020802609/custom+lint+-+research+and+use+at+leancode) for more info

[pub-badge]: https://img.shields.io/pub/v/leancode_lint
[pub-badge-link]: https://pub.dev/packages/leancode_lint
