# leancode_lint Examples

## Default configuration

```yaml
# pubspec.yaml
dev_dependencies:
  leancode_lint: ^20.0.0

# analysis_options.yaml
include: package:leancode_lint/analysis_options.yaml

plugins:
  leancode_lint: ^20.0.0
```

From this repo (path dependency):

```yaml
dev_dependencies:
  leancode_lint:
    path: ../..

plugins:
  leancode_lint:
    path: ../..
```

## Custom configuration

1. Create a plugin package (e.g. `my_lints`) that depends on `leancode_lint` and exposes a `plugin`:

   ```dart
   // my_lints/lib/main.dart
   import 'package:leancode_lint/plugin.dart';
   
   final plugin = LeanCodeLintPlugin(
     name: 'my_lints',
     config: LeanCodeLintConfig(
       catchParameterNames: CatchParameterNamesConfig(
         exception: 'error',
         stackTrace: 'stackTrace',
       ),
     ),
   );
   ```

2. Add the plugin as a dev dependency and enable it:

   ```yaml
   # pubspec.yaml
   dev_dependencies:
     my_lints:
       path: ./path/to/my_lints
   
   # analysis_options.yaml
   include: package:leancode_lint/analysis_options.yaml
   
   plugins:
     my_lints:
       path: ./path/to/my_lints
   ```

## Running

```bash
cd example/default && flutter pub get && flutter analyze
cd example/custom/app && flutter pub get && flutter analyze
```
