import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';
import 'package:leancode_lint/helpers.dart';

/// Displays warning for conditional hooks usage.
class AvoidConditionalHooks extends DartLintRule {
  AvoidConditionalHooks() : super(code: _getLintCode());

  static const ruleName = 'avoid_conditional_hooks';

  @override
  void run(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
  ) {
    context.registry.addClassDeclaration(
      (node) {
        final element = node.declaredElement;
        if (element == null) {
          return;
        }

        final isHookWidget = const TypeChecker.fromName(
          'HookWidget',
          packageName: 'flutter_hooks',
        ).isSuperOf(element);
        if (!isHookWidget) {
          return;
        }

        final buildMethod = getBuildMethod(node);
        if (buildMethod == null) {
          return;
        }

        // get all hook expressions from build method
        final hookExpressions = switch (buildMethod.body) {
          ExpressionFunctionBody(expression: final AstNode node) ||
          BlockFunctionBody(block: final AstNode node) =>
            getAllInnerHookExpressions(node),
          _ => <InvocationExpression>[],
        };

        final hooksCalledConditionally = hookExpressions.where(_isConditional);

        for (final hookExpression in hooksCalledConditionally) {
          reporter.reportErrorForNode(_getLintCode(), hookExpression);
        }
      },
    );
  }

  bool _isConditional(InvocationExpression node) {
    bool isConditional(
      AstNode node, {
      required AstNode child,
    }) {
      return switch (node) {
        IfStatement(expression: final condition) ||
        ConditionalExpression(:final condition) ||
        SwitchStatement(expression: final condition) ||
        SwitchExpression(expression: final condition) when condition != child =>
          true,
        _ => switch (node.parent) {
            final parent? => isConditional(parent, child: node),
            _ => false,
          },
      };
    }

    return isConditional(node, child: node);
  }

  static LintCode _getLintCode() => const LintCode(
        name: ruleName,
        problemMessage: "Don't use hooks conditionally",
      );
}
