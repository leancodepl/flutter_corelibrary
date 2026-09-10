import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:build/build.dart';
import 'package:jaspr_class_scope_builder/src/suffix.dart';

/// The extension of the part file the scopes are written to.
const scopesExtension = '.scopes.dart';

/// The components [source] declares with `@scopedCss`, in the order written.
///
/// Parsed without resolution: the class name is all a scope needs, and the
/// input cannot be resolved on a first build anyway, when it declares a part
/// file that does not exist yet.
List<String> scopedComponentsIn(String source) =>
    parseString(content: source, throwIfDiagnostics: false).unit.declarations
        .whereType<ClassDeclaration>()
        .where(_isScopedCss)
        .map((declaration) => declaration.namePart.typeName.lexeme)
        .toList();

/// What a component's suffix is hashed from: where it is declared, so that two
/// components of the same name never share a namespace.
String scopeSourceOf(AssetId asset, String component) =>
    '${asset.package}|${asset.path}#$component';

/// The scope of [component] in [asset], as the part file spells it.
String renderScope(AssetId asset, String component) {
  final constant = '_\$${component[0].toLowerCase()}${component.substring(1)}';
  final suffix = classScopeSuffix(scopeSourceOf(asset, component));

  return "const ${constant}Scope = ClassScope('$component', '$suffix');";
}

// Matched by the name the annotation is spelled with, rather than by resolving
// it: resolution costs a great deal more, and the class name is all this needs
// from the element model.
bool _isScopedCss(ClassDeclaration declaration) =>
    declaration.metadata.any((annotation) {
      final name = annotation.name.name.split('.').last;

      return name == 'scopedCss' || name == 'ScopedCss';
    });
