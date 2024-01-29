import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/error/error.dart';
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';
import 'package:leancode_lint/utils.dart';

/// Enforces that some widgets that accept multiple children do not have a single child.
class AvoidSingleChildInMultiChildWidgets extends DartLintRule {
  AvoidSingleChildInMultiChildWidgets() : super(code: _createCode(''));

  static LintCode _createCode(String name) => LintCode(
        name: 'avoid_single_child_in_multi_child_widgets',
        problemMessage: 'Avoid using $name with a single child.',
        correctionMessage:
            'Remove the $name and achieve the same result using dedicated widgets.',
        errorSeverity: ErrorSeverity.WARNING,
      );

  static const _complain = [
    TypeChecker.fromName(
      'Column',
      packageName: 'flutter',
    ),
    TypeChecker.fromName(
      'Row',
      packageName: 'flutter',
    ),
    TypeChecker.fromName(
      'Wrap',
      packageName: 'flutter',
    ),
    TypeChecker.fromName(
      'Flex',
      packageName: 'flutter',
    ),
  ];

  @override
  void run(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
  ) {
    context.registry.addInstanceCreationExpression((node) {
      final constructorName = node.constructorName.type;
      if (constructorName.element case final typeElement?) {
        // is it something we want to complain about?
        final matchingChecker = _complain
            .firstWhereOrNull((checker) => checker.isExactly(typeElement));
        if (matchingChecker == null) {
          return;
        }

        // does it have a children argument?
        final children = node.argumentList.arguments
            .whereType<NamedExpression>()
            .firstWhereOrNull((e) => e.name.label.name == 'children')
            ?.expression;
        if (children == null) {
          return;
        }

        _checkInstanceCreation(constructorName, children, reporter);
      }
    });
  }

  void _checkInstanceCreation(
    NamedType constructorName,
    Expression children,
    ErrorReporter reporter,
  ) {
    if (children case final ListLiteral list) {
      if (_hasSingleElement(list)) {
        reporter.reportErrorForNode(
          _createCode(constructorName.name2.lexeme),
          constructorName,
        );
      }
    }
  }

  // Conservative. If we cannot determine the number of children, return false.
  bool _hasSingleElement(ListLiteral list) {
    if (list.elements.length != 1) {
      return false;
    }

    bool checkExpression(CollectionElement expression) {
      switch (expression) {
        case Expression():
          return true;
        case ForElement() || MapLiteralEntry() || SpreadElement():
          return false;
        case IfElement(:final thenElement, :final elseElement):
          return checkExpression(thenElement) &&
              (elseElement == null || checkExpression(elseElement));
      }
    }

    return checkExpression(list.elements.first);
  }
}
