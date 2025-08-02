# leancode_lint

[![leancode_lint pub.dev badge][pub-badge]][pub-badge-link]

An opinionated set of high-quality, robust, and up-to-date lint rules used at LeanCode.

## Installation

1. Add `leancode_lint` and `custom_lint` as a dev dependency in your project's `pubspec.yaml`.

   ```sh
   dart pub add leancode_lint custom_lint --dev
   ```

2. In your `analysis_options.yaml` add `include: package:leancode_lint/analysis_options.yaml`. You might want to exclude some files
   (e.g generated json serializable) from analysis.

3. Enable the `custom_lint` analyzer plugin in `analysis_options.yaml`. You can customize lint rules by adding a `custom_lint` config
   with a `rules` section.

4. Run `flutter pub get` in your project main directory and restart your IDE. You're ready to go!

Example `analysis_options.yaml`:

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

If your package is a library rather than a binary application, you will expose some public API for users of your library. Therefore, you should use lint rules optimized for this case by just changing your `include` entry in `analysis_options.yaml`:

```yaml
include: package:leancode_lint/analysis_options_package.yaml
```

## Custom lint rules

To disable a particular custom lint rule, set the rule to false in `analysis_options.yaml`. For example, to disable `prefix_widgets_returning_slivers`:

```yaml
custom_lint:
  rules:
    - prefix_widgets_returning_slivers: false
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
try {} catch (e, s) {}
try {} on SocketException catch (e, s) {}
```

**GOOD:**

```dart
try {} catch (err, st) {}
try {} on SocketException catch (e, st) {}
```

#### Configuration

None.

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
HookBuilder(
  builder: (context) {
    return Placeholder();
  },
);
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
Builder(
  builder: (context) {
    return Placeholder();
  },
);
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

- `application_prefix`: A string. Specifies the application prefix to accept sliver prefixes. For example if set to "Lncd" then "LncdSliverMyWidget" is a valid sliver name.

```yaml
custom_lint:
  rules:
    - prefix_widgets_returning_slivers:
      application_prefix: Lncd
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

- `<preferredItem>`: The item to be preferred. A list of objects:
  - `instead_of`: A required string. Name of the item that is forbidden.
  - `from_package`: A required string. Name of the package from which that forbidden item is from.

```yaml
custom_lint:
  rules:
    - use_design_system_item:
      LncdText:
        - instead_of: Text
          from_package: flutter
        - instead_of: RichText
          from_package: flutter
      LncdScaffold:
        - instead_of: Scaffold
          from_package: flutter
```

### `avoid_single_child_in_multi_child_widgets`

**AVOID** using `Column`, `Row`, `Flex`, `Wrap`, `SliverList`, `MultiSliver`, `SliverChildListDelegate`, `SliverMainAxisGroup`, and `SliverCrossAxisGroup` with a single child.

**BAD:**

```dart
Column(
  children: [
    Container(),
  ]
)
```

**GOOD:**

```dart
Container(),
```

#### Configuration

None.

### `use_align`

**DO** Use Align widget instead of the Container widget with only the alignment parameter'

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

## Assists

Assists are IDE refactorings not related to a particular issue. They can be triggered by placing your cursor over a relevant piece of code and opening the code actions dialog. For instance, in VSCode this is done with <kbd>ctrl</kbd>+<kbd>.</kbd> or <kbd>⌘</kbd>+<kbd>.</kbd>.

See linked source code containing explanation in dart doc.

- [Convert positional to named formal](./lib/assists/convert_positional_to_named_formal.dart)
- [Convert record into nominal type](./lib/assists/convert_record_into_nominal_type.dart)
- [Convert iterable map to collection-for](./lib/assists/convert_iterable_map_to_collection_for.dart)

[pub-badge]: https://img.shields.io/pub/v/leancode_lint
[pub-badge-link]: https://pub.dev/packages/leancode_lint
