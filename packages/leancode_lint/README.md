# leancode_lint

[![leancode_lint pub.dev badge][pub-badge]][pub-badge-link]

Lint rules used internally in LeanCode projects.

## Installation

1. Add `leancode_lint` and `custom_lint` as a dev dependency in your project's `pubspec.yaml`.

```sh
dart pub add leancode_lint custom_lint --dev
```

2. In your `analysis_options.yaml` add `include: package:leancode_lint/analysis_options.yaml`. You might want to exclude some files
(e.g generated json serializable) from analysis.

4. Enable the `custom_lint` analyzer plugin in `analysis_options.yaml`. You can customize lint rules by adding a `custom_lint` config 
with `rules` like in the example below.

5. Run `flutter pub get` in your project main directory and restart your IDE. You're ready to go!
   
```yaml
include: package:leancode_lint/analysis_options.yaml

# Optional lint rules configuration
custom_lint:
  rules:
    - use_design_system_item:
      AppText:
        - instead_of: Text
          from_package: flutter
        - instead_of: RichText
          from_package: flutter
      AppScaffold:
        - instead_of: Scaffold
          from_package: flutter

analyzer:
  plugins:
    # Required for our custom lints support
    - custom_lint
  exclude:
    - '**/*.g.dart'
```

## Usage in libraries

If your package is a library rather than binary application, you will expose some public API for users of your library. Therefore, you should use lint rules optimized for this case by changing your `include` entry in `analysis_options.yaml`:

```yaml
include: package:leancode_lint/analysis_options_package.yaml
```

Within this package, you can define our own lints, assists and quick fixes.

[pub-badge]: https://img.shields.io/pub/v/leancode_lint
[pub-badge-link]: https://pub.dev/packages/leancode_lint
