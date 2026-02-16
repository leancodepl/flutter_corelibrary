# leancode_lint

[![leancode_lint pub.dev badge][pub-badge]][pub-badge-link]

An opinionated set of high-quality, robust, and up-to-date lint rules used at LeanCode.

## Usage

There are two supported ways to use this package:

1. **As-is (default configuration)** – enable the built-in `leancode_lint`
   analyzer plugin. This uses `const LeanCodeLintConfig()` defaults.
2. **With custom configuration** – create your own analyzer plugin package that
   instantiates `LeanCodeLintPlugin` with your `LeanCodeLintConfig`, then enable
   your plugin instead (see [“Configuration (custom plugin package)”](#configuration-custom-plugin-package) below).

If you only want to toggle individual rules on/off, you can do that in
`analysis_options.yaml` (see [“Custom lint rules”](#custom-lint-rules)).

## Installation

1. Add `leancode_lint` as a dev dependency in your project's `pubspec.yaml`.

   ```sh
   dart pub add leancode_lint --dev
   ```

2. In your `analysis_options.yaml` add `include: package:leancode_lint/analysis_options.yaml`.
   You might want to exclude some files (e.g generated json serializable) from analysis.

3. Enable the analyzer plugin in `analysis_options.yaml`.

   - For default behavior, enable `leancode_lint`.
   - For custom configuration, enable your own plugin package instead
     (see [“Configuration (custom plugin package)”](#configuration-custom-plugin-package) below).

4. Run `flutter pub get` in your project main directory and restart the analysis server in your IDE.
   You're ready to go!

Example `analysis_options.yaml`:

```yaml
include: package:leancode_lint/analysis_options.yaml

plugins:
  leancode_lint: ^20.0.0

analyzer:
  exclude:
    - '**/*.g.dart'
```

> [!TIP]
> See the [example/](./example) directory for complete, runnable examples
> with both default and custom configuration.

## Configuration (custom plugin package)

This section is optional. You only need it if you want to customize the
behavior of configurable rules beyond the built-in defaults.

To configure `leancode_lint` rules programmatically, create your own analyzer
plugin package (e.g. `my_lints`) that depends on `leancode_lint` and exposes a
top-level `plugin` variable.

`my_lints/lib/main.dart`:

```dart
import 'package:leancode_lint/plugin.dart';

final plugin = LeanCodeLintPlugin(
  name: 'my_lints',
  config: LeanCodeLintConfig(
    applicationPrefix: 'Lncd',
    catchParameterNames: CatchParameterNamesConfig(
      exception: 'error',
      stackTrace: 'stackTrace',
    ),
    designSystemItemReplacements: {
      'AppText': [
        DesignSystemForbiddenItem(name: 'Text', packageName: 'flutter'),
        DesignSystemForbiddenItem(name: 'RichText', packageName: 'flutter'),
      ],
      'AppScaffold': [
        DesignSystemForbiddenItem(name: 'Scaffold', packageName: 'flutter'),
      ],
    },
  ),
);
```

Then enable your plugin in the consuming project’s `analysis_options.yaml`:

```yaml
include: package:leancode_lint/analysis_options.yaml

plugins:
  my_lints:
    path: ./path/to/my_lints
```

## Usage in libraries

If your package is a library rather than a binary application, you will expose some public API for users of your library. Therefore, you should use lint rules optimized for this case by just changing your `include` entry in `analysis_options.yaml`:

```yaml
include: package:leancode_lint/analysis_options_package.yaml
```

## Custom lint rules

To disable a particular custom lint rule, set the rule to false in `analysis_options.yaml`. For example, to disable `prefix_widgets_returning_slivers`:

```yaml
plugins:
  leancode_lint:
    version: ^20.0.0
    diagnostics:
      prefix_widgets_returning_slivers: false
```

### `add_cubit_suffix_for_your_cubits`

**DO** add a 'Cubit' suffix to your cubit names.

**BAD:**

```dart
class MyClass extends Cubit<int> {}
```

**GOOD:**

```dart
class MyClassCubit extends Cubit<int> {}
```

#### Configuration

None.

### `avoid_conditional_hooks`

**AVOID** using hooks conditionally

**BAD:**

```dart
Widget build(BuildContext context) {
  if (condition) {
    useEffect(() {
      // ...
    }, []);
  }
}
```

**BAD:**

```dart
Widget build(BuildContext context) {
  final controller = this.controller ?? useTextEditingController();
}
```

**BAD:**

```dart
Widget build(BuildContext context) {
  if (condition) {
    return Text('Early return');
  }

  final state = useState(0);
}
```

**GOOD:**

```dart
Widget build(BuildContext context) {
  useEffect(() {
    if (condition) {
        // ...
    }
  }, []);
}
```

**GOOD:**

```dart
Widget build(BuildContext context) {
  final backingController = useTextEditingController();
  final controller = this.controller ?? backingController;
}
```

**GOOD:**

```dart
Widget build(BuildContext context) {
  final state = useState(0);

  if (condition) {
    return Text('Early return');
  }
}
```

#### Configuration

None.

### `catch_parameter_names`

**DO** name catch clause parameters consistently

- if it's a catch-all, the exception should be named `err` and the stacktrace `st`
- if it's a typed catch, the stacktrace has to be named `st`

**BAD:**

```dart
void f() {
  try {} catch (e, s) {}
  try {} on SocketException catch (e, s) {}
}
```

**GOOD:**

```dart
void f() {
  try {} catch (err, st) {}
  try {} on SocketException catch (e, st) {}
}
```

**GOOD:**

With custom config: exception: error, stack_trace: stackTrace

```dart
void f() {
  try {} catch (error, stackTrace) {}
  try {} on SocketException catch (error, stackTrace) {}
}
```

#### Configuration

Configured via `LeanCodeLintConfig.catchParameterNames`:

```dart
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

### `hook_widget_does_not_use_hooks`

**AVOID** extending `HookWidget` if no hooks are used.

**BAD:**

```dart
class MyWidget extends HookWidget {
  @override
  Widget build(BuildContext context) {
    return Placeholder();
  }
}
```

**BAD:**

```dart
class MyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return HookBuilder(
      builder: (context) {
        return Placeholder();
      },
    );
  }
}
```

**GOOD:**

```dart
class MyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Placeholder();
  }
}
```

**GOOD:**

```dart
Widget build(BuildContext context) {
  return Builder(
    builder: (context) {
      return Placeholder();
    },
  );
}
```

#### Configuration

None.

### `prefix_widgets_returning_slivers`

**DO** prefix widget names with 'Sliver' if the widget returns slivers.

**BAD:**

```dart
class MyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter();
  }
}
```

**GOOD:**

```dart
class SliverMyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter();
  }
}
```

#### Configuration

- `application_prefix`: A string. Specifies the application prefix to accept sliver prefixes.
  For example if set to "Lncd" then "LncdSliverMyWidget" is a valid sliver name.

Configured via `LeanCodeLintConfig.applicationPrefix`:

```dart
import 'package:leancode_lint/plugin.dart';

final plugin = LeanCodeLintPlugin(
  name: 'my_lints',
  config: LeanCodeLintConfig(applicationPrefix: 'Lncd'),
);
```

### `start_comments_with_space`

**DO** start comments/docs with an empty space.

**BAD:**

```dart
//some comment
///some doc
```

**GOOD:**

```dart
// some comment
/// some doc
```

#### Configuration

None.

### `use_design_system_item`

**AVOID** using items disallowed by the design system.

This rule has to be configured to do anything. The rule will highlight forbidden usages and suggest alternatives preferred by the design system.

#### Configuration

Configured via `LeanCodeLintConfig.designSystemItemReplacements`:

```dart
import 'package:leancode_lint/plugin.dart';

final plugin = LeanCodeLintPlugin(
  name: 'my_lints',
  config: LeanCodeLintConfig(
    designSystemItemReplacements: {
      'LncdText': [
        DesignSystemForbiddenItem(name: 'Text', packageName: 'flutter'),
        DesignSystemForbiddenItem(name: 'RichText', packageName: 'flutter'),
      ],
      'LncdScaffold': [
        DesignSystemForbiddenItem(name: 'Scaffold', packageName: 'flutter'),
      ],
    },
  ),
);

```

### `avoid_single_child_in_multi_child_widgets`

**AVOID** using `Column`, `Row`, `Flex`, `Wrap`, `SliverList`, `MultiSliver`, `SliverChildListDelegate`, `SliverMainAxisGroup`, and `SliverCrossAxisGroup` with a single child.

**BAD:**

```dart
Widget build(BuildContext context) {
  return Column(
    children: [
      Container(),
    ],
  );
}
```

**GOOD:**

```dart
Widget build(BuildContext context) {
  return Container();
}
```

#### Configuration

None.

### `use_dedicated_media_query_methods`

**AVOID** using `MediaQuery.of` or `MediaQuery.maybeOf` to access only one property. Instead, prefer dedicated methods, for example `MediaQuery.paddingOf(context)`.

Dedicated methods offer better performance by minimizing unnecessary widget rebuilds.

**BAD:**

```dart
Widget build(BuildContext context) {
  final size = MediaQuery.of(context).size;
  return const SizedBox();
}
```

**GOOD:**

```dart
Widget build(BuildContext context) {
  final size = MediaQuery.sizeOf(context);
  return const SizedBox();
}
```

#### Configuration

None.

### `use_align`

**DO** Use the Align widget instead of the Container widget with only the alignment parameter.

**BAD:**

```dart
class MyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.bottomCenter,
      child: const SizedBox(),
    );
  }
}
```

**GOOD:**

```dart
class MyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Align(
      alignment: Alignment.bottomCenter,
      child: SizedBox(),
    );
  }
}
```

#### Configuration

None

### `use_padding`

**DO** Use Padding widget instead of the Container widget with only the margin parameter

**BAD:**

```dart
class MyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(10),
      child: const SizedBox(),
    );
  }
}
```

**GOOD:**

```dart
class MyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(10),
      child: SizedBox(),
    );
  }
}
```

#### Configuration

None

### `prefer_center_over_align`

**DO** Use the Center widget instead of the Align widget with the alignment parameter set to Alignment.center

**BAD:**

```dart
class MyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Align(
      child: SizedBox(),
    );
  }
}
```

**GOOD:**

```dart
class MyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Center(
      child: SizedBox(),
    );
  }
}
```

#### Configuration

None

### `prefer_equatable_mixin`

**DO** mix in `EquatableMixin` instead of extending `Equatable`.

**BAD:**

```dart
import 'package:equatable/equatable.dart';

class Foobar extends Equatable {
  const Foobar(this.value);

  final int value;

  @override
  List<Object?> get props => [value];
}
```

**GOOD:**

```dart
import 'package:equatable/equatable.dart';

class Foobar with EquatableMixin {
  const Foobar(this.value);

  final int value;

  @override
  List<Object?> get props => [value];
}
```

#### Configuration

None.

## Assists

Assists are IDE refactorings not related to a particular issue. They can be triggered by placing your cursor over a relevant piece of code and opening the code actions dialog. For instance, in VSCode this is done with <kbd>ctrl</kbd>+<kbd>.</kbd> or <kbd>⌘</kbd>+<kbd>.</kbd>.

See linked source code containing explanation in dart doc.

- [Convert positional to named formal](./lib/src/assists/convert_positional_to_named_formal.dart)
- [Convert record into nominal type](./lib/src/assists/convert_record_into_nominal_type.dart)
- [Convert iterable map to collection-for](./lib/src/assists/convert_iterable_map_to_collection_for.dart)

[pub-badge]: https://img.shields.io/pub/v/leancode_lint
[pub-badge-link]: https://pub.dev/packages/leancode_lint
