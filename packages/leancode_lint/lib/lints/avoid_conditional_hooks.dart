import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/token.dart';
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

        final conditionaHookTokens = switch (buildMethod.body) {
          ExpressionFunctionBody(:final expression) =>
            getAllInnerHookExpressions(expression)
                .where(_isConditional)
                .map((expression) => expression.beginToken),
          BlockFunctionBody(:final block) =>
            block.statements.expand(_getConditionalHooksTokens),
          _ => <Token>[],
        };

        for (final token in conditionaHookTokens) {
          reporter.reportErrorForOffset(
            _getLintCode(),
            token.offset,
            token.length,
          );
        }
      },
    );
  }

  bool _isConditional(
    AstNode node, {
    bool deepSearch = true,
    AstNode? child,
  }) =>
      switch (node) {
        IfStatement(:final expression) ||
        ConditionalExpression(condition: final expression) ||
        SwitchStatement(:final expression) ||
        SwitchExpression(:final expression) when expression != child =>
          true,
        _ => switch (deepSearch) {
            true => switch (node.parent) {
                final parent? => _isConditional(parent, child: node),
                _ => false,
              },
            _ => false,
          }
      };

  Iterable<Token> _getConditionalHooksTokens(Statement node) {
    final conditionalHooksTokens = <Token>[];

    final innerHooks = getAllStatementsContainingHooks(node);
    final isInConditionalStatement = _isConditional(node);

    for (final hook in innerHooks) {
      if (hook case VariableDeclarationStatement(:final variables)) {
        for (final variable in variables.variables) {
          final expression = variable.initializer;

          switch (expression) {
            case ConditionalExpression(
                :final thenExpression,
                :final elseExpression,
              ):
              [thenExpression, elseExpression]
                  .where(
                    (expression) =>
                        getAllInnerHookExpressions(expression).isNotEmpty,
                  )
                  .forEach(
                    (hookExpression) => conditionalHooksTokens.add(
                      hookExpression.beginToken,
                    ),
                  );
            case final _?
                when getAllInnerHookExpressions(expression).isNotEmpty &&
                    isInConditionalStatement:
              conditionalHooksTokens.add(expression.beginToken);
          }
        }
      } else if (isInConditionalStatement) {
        conditionalHooksTokens.add(hook.beginToken);
      }
    }

    return conditionalHooksTokens;
  }

  static LintCode _getLintCode() => const LintCode(
        name: ruleName,
        problemMessage: "Don't use conditional hooks",
      );
}
