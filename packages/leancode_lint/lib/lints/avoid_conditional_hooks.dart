import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/token.dart';
import 'package:analyzer/error/error.dart';
import 'package:analyzer/src/lint/linter.dart';
import 'package:leancode_lint/helpers.dart';

/// Displays warning for conditional hooks usage.
class AvoidConditionalHooks extends AnalysisRule {
  AvoidConditionalHooks()
    : super(
        name: 'avoid_conditional_hooks',
        description: "Don't use hooks conditionally",
      );

  @override
  LintCode get lintCode => LintCode(name, description);

  @override
  void registerNodeProcessors(
    NodeLintRegistry registry,
    LinterContext context,
  ) {
    registry.addHookWidgetBody(this, (node, diagnosticNode) {
      // get all hook expressions from build method
      final hookExpressions = switch (node) {
        ExpressionFunctionBody(expression: final AstNode node) ||
        BlockFunctionBody(
          block: final AstNode node,
        ) => getAllInnerHookExpressions(node),
        _ => <InvocationExpression>[],
      };

      final returnExpressions = getAllReturnExpressions(node).nonNulls;
      // everything past that return is considered conditional
      final firstReturn =
          returnExpressions.isEmpty
              ? null
              : returnExpressions.reduce(
                (acc, curr) => acc.offset < curr.offset ? acc : curr,
              );

      for (final hookExpression in hookExpressions) {
        if (_isConditional(firstReturn, hookExpression, node)) {
          reportLint(hookExpression);
        }
      }
    });
  }

  /// Check if node is present in any conditional branch
  bool _isConditional(
    Expression? firstReturn,
    InvocationExpression node,
    FunctionBody body,
  ) {
    bool isConditional(AstNode node, {required AstNode child}) {
      return switch (node) {
        IfStatement(expression: final condition) ||
        IfElement(expression: final condition) ||
        ConditionalExpression(:final condition) ||
        SwitchStatement(expression: final condition) ||
        SwitchExpression(
          expression: final condition,
        ) when condition != child => true,
        BinaryExpression(
          operator: Token(
            type: TokenType.QUESTION_QUESTION ||
                TokenType.AMPERSAND_AMPERSAND ||
                TokenType.BAR_BAR,
          ),
          :final rightOperand,
        )
            when rightOperand == child =>
          true,
        AssignmentExpression(
          operator: Token(
            type: TokenType.QUESTION_QUESTION_EQ ||
                TokenType.AMPERSAND_EQ ||
                TokenType.BAR_EQ ||
                TokenType.CARET_EQ,
          ),
          :final rightHandSide,
        )
            when rightHandSide == child =>
          true,
        // don't escape defining function bodies
        _ when node == body => false,
        _ => switch (node.parent) {
          final parent? => isConditional(parent, child: node),
          _ => false,
        },
      };
    }

    bool isBefore(Expression firstReturn, InvocationExpression node) {
      return firstReturn.offset < node.offset &&
          // make sure the hook isn't inside of the return
          !firstReturn.sourceRange.covers(node.sourceRange);
    }

    return isConditional(node, child: node) ||
        (firstReturn != null && isBefore(firstReturn, node));
  }
}
