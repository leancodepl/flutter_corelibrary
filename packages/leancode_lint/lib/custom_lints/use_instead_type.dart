import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/error/error.dart';
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

/// Enforces that items that have replacements defined are used.
abstract base class UseInsteadType extends DartLintRule {
  UseInsteadType({
    /// preferred item -> forbidden items
    required Map<String, List<(String packageName, String itemName)>>
        replacements,
    required this.lintCodeName,
    this.errorSeverity = ErrorSeverity.WARNING,
  })  : _checkers = [
          for (final MapEntry(key: preferredItemName, value: forbidden)
              in replacements.entries)
            (
              preferredItemName,
              TypeChecker.any([
                for (final (package, name) in forbidden)
                  if (package.startsWith('dart:'))
                    TypeChecker.fromUrl('$package#$name')
                  else
                    TypeChecker.fromName(name, packageName: package),
              ])
            ),
        ],
        super(
          code: LintCode(
            name: lintCodeName,
            problemMessage: 'This item is forbidden',
          ),
        );

  final List<(String preferredItemName, TypeChecker)> _checkers;
  final String lintCodeName;
  final ErrorSeverity errorSeverity;

  String problemMessage(String itemName);
  String correctionMessage(String preferredItemName);

  @override
  bool isEnabled(CustomLintConfigs configs) {
    return _checkers.isNotEmpty;
  }

  LintCode _createCode({
    required String itemName,
    required String preferredItemName,
  }) =>
      LintCode(
        name: lintCodeName,
        problemMessage: problemMessage(itemName),
        correctionMessage: correctionMessage(preferredItemName),
        errorSeverity: errorSeverity,
      );

  @override
  void run(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
  ) {
    context.registry.addIdentifier((node) {
      if (node.staticElement case final element?) {
        _handleElement(reporter, element, node);
      }
    });
    context.registry.addNamedType((node) {
      if (node.element case final element?) {
        _handleElement(reporter, element, node);
      }
    });
  }

  void _handleElement(
    ErrorReporter reporter,
    Element element,
    AstNode node,
  ) {
    for (final (preferredItemName, checker) in _checkers) {
      try {
        if (checker.isExactly(element)) {
          reporter.reportErrorForNode(
            _createCode(
              itemName: element.displayName,
              preferredItemName: preferredItemName,
            ),
            node,
          );
        }
      } catch (err) {
        // isExactly crashes sometimes
      }
    }
  }
}
