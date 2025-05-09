import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/error/error.dart' hide LintCode;
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';
import 'package:leancode_lint/common_type_checkers.dart';
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
    ('children', TypeCheckers.column),
    ('children', TypeCheckers.row),
    ('children', TypeCheckers.wrap),
    ('children', TypeCheckers.flex),
    ('children', TypeCheckers.sliverList),
    ('slivers', TypeCheckers.sliverMainAxisGroup),
    ('slivers', TypeCheckers.sliverCrossAxisGroup),
    ('children', TypeCheckers.multiSliver),
    ('children', TypeCheckers.sliverChildListDelegate),
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
        final match = _complain.firstWhereOrNull(
          (e) => e.$2.isExactly(typeElement),
        );
        if (match == null) {
          return;
        }

        // does it have a children argument?
        var children = node.argumentList.arguments.firstWhereOrNull(
          (e) => e.staticParameterElement?.name == match.$1,
        );
        if (children == null) {
          return;
        } else if (children is NamedExpression) {
          children = children.expression;
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
        reporter.atNode(
          constructorName,
          _createCode(constructorName.name2.lexeme),
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
      return switch (expression) {
        Expression() => true,
        ForElement() || MapLiteralEntry() || SpreadElement() => false,
        IfElement(:final thenElement, :final elseElement) =>
          checkExpression(thenElement) &&
              (elseElement == null || checkExpression(elseElement)),
        NullAwareElement(:final value) => checkExpression(value),
      };
    }

    return checkExpression(list.elements.first);
  }
}
