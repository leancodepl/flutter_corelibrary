import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:build/build.dart';
import 'package:jaspr_class_scope/jaspr_class_scope.dart';

/// Writes the class-name scope of every component annotated with `@scopedCss`.
///
/// For `lib/components/hero.dart` declaring `@scopedCss class Hero`, it writes
/// `lib/components/hero.scopes.dart` holding
///
/// ```dart
/// const _$heroScope = ClassScope.literal('Hero', '<suffix>');
/// ```
///
/// where the suffix is hashed from the asset the class is declared in —
/// `package|lib/components/hero.dart#Hero` — and not from the bare class name.
/// Two components called `Hero` in two files therefore get two suffixes,
/// without either of them having to know about the other, and without the
/// class name reaching the page through `Type.toString()`, which a minifying
/// compiler is free to rewrite.
///
/// Moving or renaming the file changes the suffix, the same way it does for
/// CSS modules; nothing outside the generated stylesheet and markup depends on
/// it.
final class ClassScopeBuilder implements Builder {
  /// The builder `build.yaml` instantiates.
  const ClassScopeBuilder();

  /// The extension of the part file this builder writes.
  static const outputExtension = '.scopes.dart';

  @override
  Map<String, List<String>> get buildExtensions => const {
    '.dart': [outputExtension],
  };

  @override
  Future<void> build(BuildStep buildStep) async {
    final input = buildStep.inputId;
    // Our own output is a `.dart` asset too, and would otherwise come back in.
    if (input.path.endsWith(outputExtension)) {
      return;
    }

    final unit =
        parseString(
          content: await buildStep.readAsString(input),
          path: input.path,
          throwIfDiagnostics: false,
        ).unit;

    final components =
        unit.declarations
            .whereType<ClassDeclaration>()
            .where(_isScopedCss)
            .map((declaration) => declaration.namePart.typeName.lexeme)
            .toList();

    if (components.isEmpty) {
      return;
    }

    final output = input.changeExtension(outputExtension);
    await buildStep.writeAsString(output, _render(input, components));
  }

  bool _isScopedCss(ClassDeclaration declaration) =>
      declaration.metadata.any((annotation) {
        // `@scopedCss`, `@ScopedCss()`, or either behind an import prefix.
        final name = annotation.name.name.split('.').last;
        return name == 'scopedCss' || name == 'ScopedCss';
      });

  String _render(AssetId input, List<String> components) {
    final file = input.pathSegments.last;
    final buffer =
        StringBuffer()
          ..writeln('// GENERATED CODE - DO NOT MODIFY BY HAND')
          ..writeln('// Written by jaspr_class_scope_builder.')
          ..writeln()
          ..writeln("part of '$file';");

    for (final component in components) {
      final source = '${input.package}|${input.path}#$component';
      final constant =
          '_\$${component[0].toLowerCase()}${component.substring(1)}Scope';

      buffer
        ..writeln()
        ..writeln('/// The class-name scope of [$component], hashed from')
        ..writeln('/// `$source`.')
        ..writeln(
          "const $constant = ClassScope.literal('$component', "
          "'${classScopeSuffix(source)}');",
        );
    }

    return buffer.toString();
  }
}
