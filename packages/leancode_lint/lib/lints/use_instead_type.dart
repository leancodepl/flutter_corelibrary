import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:analyzer/error/error.dart' hide LintCode;
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

typedef ForbiddenItem = ({String name, String packageName});

/// Enforces that items that have replacements defined are used.
abstract base class UseInsteadType extends DartLintRule {
  UseInsteadType({
    /// preferred item -> forbidden items
    required Map<String, List<ForbiddenItem>> replacements,
    required String lintCodeName,
    required String problemMessage,
    required String correctionMessage,
    ErrorSeverity errorSeverity = ErrorSeverity.WARNING,
  }) : _checkers = [
         for (final MapEntry(key: preferredItemName, value: forbidden)
             in replacements.entries)
           (
             preferredItemName,
             TypeChecker.any([
               for (final (:name, :packageName) in forbidden)
                 if (packageName.startsWith('dart:'))
                   TypeChecker.fromUrl('$packageName#$name')
                 else
                   TypeChecker.fromName(name, packageName: packageName),
             ]),
           ),
       ],
       super(
         code: LintCode(
           name: lintCodeName,
           problemMessage: problemMessage,
           correctionMessage: correctionMessage,
           errorSeverity: errorSeverity,
         ),
       );

  final List<(String preferredItemName, TypeChecker)> _checkers;

  @override
  bool isEnabled(CustomLintConfigs configs) {
    return _checkers.isNotEmpty;
  }

  @override
  void run(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
  ) {
    context.registry.addIdentifier((node) {
      if (node.staticType case final type?) {
        _handleElement(reporter, type, node);
      }
    });
    context.registry.addNamedType((node) {
      if (node.type case final type?) {
        _handleElement(reporter, type, node);
      }
    });
  }

  void _handleElement(ErrorReporter reporter, DartType type, AstNode node) {
    if (_isInHide(node)) {
      return;
    }

    for (final (preferredItemName, checker) in _checkers) {
      try {
        if (checker.isExactlyType(type)) {
          reporter.atNode(
            node,
            code,
            arguments: [type.getDisplayString(), preferredItemName],
          );
        }
      } catch (err) {
        // isExactly crashes sometimes
      }
    }
  }

  bool _isInHide(AstNode node) {
    if (node.parent case final parent?) {
      if (parent is HideCombinator) {
        return true;
      }
      return _isInHide(parent);
    } else {
      return false;
    }
  }
}
