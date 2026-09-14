import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:jaspr_class_scope_builder/src/suffix.dart';

/// The extension of the part file the scopes are written to.
const scopesExtension = '.scopes.dart';

/// Where a package lists its scopes for the check. An asset of the build
/// cache, never a file in anyone's `lib/`; the path has to begin with `lib/`
/// because that is all another package's build sees of a dependency.
const manifestAsset = 'lib/jaspr_class_scope.scopes.json';

/// The components [asset] declares with `@scopedCss`.
Future<List<String>> scopedComponentsIn(
  BuildStep buildStep,
  AssetId asset,
) async {
  final source = await buildStep.readAsString(asset);

  // Resolving is what the rest of this costs, and a file without the
  // annotation's name, or without the part file to write the scopes into, has
  // nothing for us either way.
  if (!source.contains('scopedCss') && !source.contains('ScopedCss')) {
    return const [];
  }
  if (!_declaresScopes(
    parseString(content: source, throwIfDiagnostics: false).unit,
  )) {
    return const [];
  }

  // A part file can declare parts of its own, and resolving one as a library
  // throws.
  if (!await buildStep.resolver.isLibrary(asset)) {
    return const [];
  }

  // The part file it declares does not exist on a first build, which is a
  // resolution error and not a syntax one.
  final library = await buildStep.resolver.libraryFor(
    asset,
    allowSyntaxErrors: true,
  );

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

// The file asks for the part file this builder writes, which is both what
// makes it ours to generate for and a reason not to resolve the rest.
bool _declaresScopes(CompilationUnit unit) => unit.directives
    .whereType<PartDirective>()
    .any((it) => it.uri.stringValue?.endsWith(scopesExtension) ?? false);

// Where the annotation is declared, not how it is spelled: a project may
// re-export `scopedCss` under its own name, and another package may declare
// something of the same name that is not ours.
bool _isScopedCss(ClassElement component) =>
    component.metadata.annotations.any((annotation) {
      final uri = annotation.element?.library?.uri;

      return uri != null &&
          uri.scheme == 'package' &&
          uri.pathSegments.first == 'jaspr_class_scope';
    });
