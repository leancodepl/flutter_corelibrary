import 'package:build/build.dart';
import 'package:jaspr_class_scope_builder/src/scoped_components.dart';

/// Writes the class-name scope of every component annotated with `@scopedCss`.
///
/// For `lib/components/hero.dart` declaring `class Hero`, it writes
/// `lib/components/hero.scopes.dart` holding
/// `const _$heroScope = ClassScope('Hero', '<suffix>')`, the suffix hashed
/// from where the class is declared — `package|lib/components/hero.dart#Hero`
/// — rather than from its bare name. Two `Hero` classes in two files therefore
/// get two suffixes.
///
/// Moving the file, or renaming the class, changes the suffix; only the
/// generated stylesheet and markup depend on it.
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
        ..writeln('/// The class-name scope of [$component], hashed from')
        ..writeln('/// `${scopeSourceOf(input, component)}`.')
        ..writeln(renderScope(input, component));
    }

    await buildStep.writeAsString(
      input.changeExtension(scopesExtension),
      scopes.toString(),
    );
  }
}
