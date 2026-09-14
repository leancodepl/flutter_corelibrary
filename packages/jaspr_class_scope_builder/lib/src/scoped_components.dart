import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:jaspr_class_scope_builder/src/suffix.dart';

/// The extension of the part file the scopes are written to.
const scopesExtension = '.scopes.dart';

/// Where a package lists its scopes for the check. A build cache asset; the
/// path begins with `lib/` because that is all a build sees of a dependency.
const manifestAsset = 'lib/jaspr_class_scope.scopes.json';

/// The components [asset] declares with `@scopedCss`.
Future<List<String>> scopedComponentsIn(
  BuildStep buildStep,
  AssetId asset,
) async {
  final source = await buildStep.readAsString(asset);

  // Resolving is the expensive part.
  if (!source.contains('scopedCss') && !source.contains('ScopedCss')) {
    return const [];
  }
  if (!_declaresScopes(
    parseString(content: source, throwIfDiagnostics: false).unit,
  )) {
    return const [];
  }

  // Resolving a part file as a library throws.
  if (!await buildStep.resolver.isLibrary(asset)) {
    return const [];
  }

  final library = await buildStep.resolver.libraryFor(asset);

  return [
    for (final component in library.classes)
      if (component.name case final name? when _isScopedCss(component)) name,
  ];
}

/// What a component's suffix is hashed from: where it is declared.
String scopeSourceOf(AssetId asset, String component) =>
    '${asset.package}|${asset.path}#$component';

/// How a clash names [component] in [asset].
String scopeOwnerOf(AssetId asset, String component) =>
    '$component (${asset.package}|${asset.path})';

/// The scope of [component] in [asset], as the part file spells it.
String renderScope(AssetId asset, String component) {
  final suffix = classScopeSuffix(scopeSourceOf(asset, component));

  return "const _\$${component}Scope = ClassScope('$component', '$suffix');";
}

bool _declaresScopes(CompilationUnit unit) => unit.directives
    .whereType<PartDirective>()
    .any((it) => it.uri.stringValue?.endsWith(scopesExtension) ?? false);

bool _isScopedCss(ClassElement component) =>
    component.metadata.annotations.any((annotation) {
      final uri = annotation.element?.library?.uri;

      return uri != null &&
          uri.scheme == 'package' &&
          uri.pathSegments.first == 'jaspr_class_scope';
    });
