import 'package:build/build.dart';
import 'package:jaspr_class_scope_builder/src/scoped_components.dart';

/// Writes the scope of every component annotated with `@scopedCss`.
///
/// `lib/components/hero.dart` declaring `class Hero` gets a
/// `lib/components/hero.scopes.dart` holding
/// `const _$heroScope = ClassScope('Hero', '<suffix>')`.
final class ClassScopeBuilder implements Builder {
  /// The builder `build.yaml` instantiates.
  const ClassScopeBuilder();

  @override
  Map<String, List<String>> get buildExtensions => const {
    '.dart': [scopesExtension],
  };

  @override
  Future<void> build(BuildStep buildStep) async {
    final input = buildStep.inputId;
    final components = scopedComponentsIn(await buildStep.readAsString(input));
    if (components.isEmpty) {
      return;
    }

    final scopes =
        StringBuffer()
          ..writeln('// GENERATED CODE - DO NOT MODIFY BY HAND')
          ..writeln('// Written by jaspr_class_scope_builder.')
          ..writeln()
          ..writeln("part of '${input.pathSegments.last}';");

    for (final component in components) {
      scopes
        ..writeln()
        ..writeln("/// The scope of [$component]'s class names.")
        ..writeln(renderScope(input, component));
    }

    await buildStep.writeAsString(
      input.changeExtension(scopesExtension),
      scopes.toString(),
    );
  }
}
