import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/error/error.dart' hide LintCode;
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';
import 'package:leancode_lint/utils.dart';

/// Enforces that some widgets that accept multiple children do not have a single child.
class AvoidSingleChildInMultiChildWidgets extends DartLintRule {
  const AvoidSingleChildInMultiChildWidgets()
    : super(
        code: const LintCode(
          name: 'avoid_single_child_in_multi_child_widgets',
          problemMessage: 'Avoid using {0} with a single child.',
          correctionMessage:
              'Remove the {0} and achieve the same result using dedicated widgets.',
          errorSeverity: DiagnosticSeverity.WARNING,
        ),
      );

  static const _complain = [
    ('children', TypeChecker.fromName('Column', packageName: 'flutter')),
    ('children', TypeChecker.fromName('Row', packageName: 'flutter')),
    ('children', TypeChecker.fromName('Wrap', packageName: 'flutter')),
    ('children', TypeChecker.fromName('Flex', packageName: 'flutter')),
    ('children', TypeChecker.fromName('SliverList', packageName: 'flutter')),
    (
      'slivers',
      TypeChecker.fromName('SliverMainAxisGroup', packageName: 'flutter'),
    ),
    (
      'slivers',
      TypeChecker.fromName('SliverCrossAxisGroup', packageName: 'flutter'),
    ),
    (
      'children',
      TypeChecker.fromName('MultiSliver', packageName: 'sliver_tools'),
    ),
    (
      'children',
      TypeChecker.fromName('SliverChildListDelegate', packageName: 'flutter'),
    ),
  ];

  @override
  void run(
    CustomLintResolver resolver,
    DiagnosticReporter reporter,
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
          (e) => e.correspondingParameter?.name == match.$1,
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
    DiagnosticReporter reporter,
  ) {
    if (children case final ListLiteral list) {
      if (_hasSingleElement(list)) {
        reporter.atNode(
          constructorName,
          code,
          arguments: [constructorName.name.lexeme],
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
