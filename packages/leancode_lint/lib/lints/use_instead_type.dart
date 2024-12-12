import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/error/error.dart';
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

typedef ForbiddenItem = ({String name, String packageName});

/// Enforces that items that have replacements defined are used.
abstract base class UseInsteadType extends DartLintRule {
  UseInsteadType({
    /// preferred item -> forbidden items
    required Map<String, List<ForbiddenItem>> replacements,
    required this.lintCodeName,
    this.errorSeverity = ErrorSeverity.WARNING,
  })  : _checkers = [
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
    if (_isInHide(node)) {
      return;
    }

    for (final (preferredItemName, checker) in _checkers) {
      try {
        if (checker.isExactly(element)) {
          reporter.atNode(
            node,
            _createCode(
              itemName: element.displayName,
              preferredItemName: preferredItemName,
            ),
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
