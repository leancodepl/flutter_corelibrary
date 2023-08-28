import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

class AddSliverPrefixForWidgetReturningSliver extends DartLintRule {
  AddSliverPrefixForWidgetReturningSliver() : super(code: _getLintCode());

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

        final expressions = _substractReturnExpressions(buildMethod.body);

        final isSliver = _anyReturnsSliver(expressions);

        if (node case ClassDeclaration(:final declaredElement?) when isSliver) {
          reporter.reportErrorForElement(
            _getLintCode(node.name.lexeme),
            declaredElement,
          );
        }
      },
    );
  }

  MethodDeclaration? _getBuildMethod(ClassDeclaration node) {
    try {
      return node.members.firstWhere(
        (member) =>
            member is MethodDeclaration && member.name.lexeme == 'build',
      ) as MethodDeclaration;
    } catch (e) {
      return null;
    }
  }

  bool _hasSliverPrefix(String className) =>
      ['Sliver', '_Sliver'].any(className.startsWith);

  bool _anyReturnsSliver(Iterable<Expression> expressions) => expressions.any(
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

  Iterable<Expression> _substractReturnExpressions(FunctionBody body) =>
      switch (body) {
        ExpressionFunctionBody(:final expression) => [expression],
        // ignore: cast_nullable_to_non_nullable
        BlockFunctionBody(:final block) => block.statements
            .whereType<ReturnStatement>()
            .map((e) => e.expression)
            .toList()
            .removeWhere((element) => element == null) as Iterable<Expression>,
        _ => <Expression>[],
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
      name: 'add_sliver_prefix_for_widget_returning_sliver',
      problemMessage: problemMessageBase,
      correctionMessage: exampleName != null ? 'Ex. Sliver$exampleName' : null,
    );
  }
}
