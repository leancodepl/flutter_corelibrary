import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/error/listener.dart';
import 'package:collection/collection.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';
import 'package:leancode_lint/helpers.dart';

/// Displays warning for widgets which return slivers but do not have the
/// `Sliver` or `_Sliver` prefix in their name.
class AddSliverPrefixForWidgetReturningSliver extends DartLintRule {
  AddSliverPrefixForWidgetReturningSliver() : super(code: _getLintCode());

  static const ruleName = 'add_sliver_prefix_for_widget_returning_sliver';

  @override
  void run(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
  ) {
    context.registry.addClassDeclaration(
      (node) {
        final isWidgetClass = _isWidgetClass(node);
        if (!isWidgetClass) {
          return;
        }

        final startsWithSliver = _hasSliverPrefix(node.name.lexeme);
        if (startsWithSliver) {
          return;
        }

        final buildMethod = _getBuildMethod(node);
        if (buildMethod == null) {
          return;
        }

        // Get all return expressions from build method
        final returnExpressions = switch (buildMethod.body) {
          ExpressionFunctionBody(:final expression) => [expression],
          BlockFunctionBody(:final block) =>
            block.statements.expand(getAllInnerReturnStatements).toList(),
          _ => <Expression>[],
        };

        final isSliver = _anyIsSliver(returnExpressions.whereNotNull());

        if (node case ClassDeclaration(:final declaredElement?) when isSliver) {
          reporter.reportErrorForElement(
            _getLintCode(node.name.lexeme),
            declaredElement,
          );
        }
      },
    );
  }

  MethodDeclaration? _getBuildMethod(ClassDeclaration node) => node.members
      .whereType<MethodDeclaration>()
      .firstWhereOrNull((member) => member.name.lexeme == 'build');

  bool _hasSliverPrefix(String className) =>
      ['Sliver', '_Sliver'].any(className.startsWith);

  bool _anyIsSliver(Iterable<Expression> expressions) => expressions.any(
        (expression) =>
            expression is InstanceCreationExpression &&
            _hasSliverPrefix(expression.constructorName.type.name2.lexeme),
      );

  bool _isWidgetClass(ClassDeclaration node) => switch (node.declaredElement) {
        final element? => const TypeChecker.any([
            TypeChecker.fromName('StatelessWidget', packageName: 'flutter'),
            TypeChecker.fromName('State', packageName: 'flutter'),
          ]).isSuperOf(element),
        _ => false,
      };

  static LintCode _getLintCode([String? className]) {
    const problemMessageBase =
        'Add sliver prefix for widget that returns sliver in build method.';

    final exampleName = switch (className) {
      final name? when name.endsWith('State') =>
        name.replaceAll('_', '').replaceAll('State', ''),
      null => null,
      _ => className,
    };

    return LintCode(
      name: ruleName,
      problemMessage: problemMessageBase,
      correctionMessage: exampleName != null
          ? 'Ex. Sliver$exampleName or _Sliver$exampleName'
          : null,
    );
  }
}
