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
    context.registry.addStatement(
      (node) {
        final innerHooks = getAllInnerHookStatements(node);
        final isInConditionalStatement = _isConditionalStatement(node);

        for (final hook in innerHooks) {
          if (hook case VariableDeclarationStatement(:final variables)) {
            for (final variable in variables.variables) {
              final expression = variable.initializer;

              if (expression != null &&
                  isHook(expression) &&
                  expression is ConditionalExpression) {
                reporter.reportErrorForOffset(
                  _getLintCode(),
                  expression.beginToken.offset,
                  expression.length,
                );
              }
            }
          } else if (isInConditionalStatement) {
            reporter.reportErrorForOffset(
              _getLintCode(),
              hook.beginToken.offset,
              hook.length,
            );
          }
        }
      },
    );
  }

  bool _isConditionalStatement(Statement statement) => switch (statement) {
        IfStatement() => true,
        _ => false,
      };

  static LintCode _getLintCode() => const LintCode(
        name: ruleName,
        problemMessage: "Don't use conditional hooks",
      );
}
