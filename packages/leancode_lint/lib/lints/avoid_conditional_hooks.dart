import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/token.dart';
import 'package:analyzer/error/error.dart';
import 'package:analyzer_plugin/utilities/range_factory.dart';
import 'package:leancode_lint/helpers.dart';

/// Displays warning for conditional hooks usage.
class AvoidConditionalHooks extends AnalysisRule {
  AvoidConditionalHooks()
    : super(
        name: code.name,
        description:
            'Do not call hooks inside conditional branches or after early returns '
            'within a HookWidget build method. Hooks must be invoked unconditionally '
            'in the same order on every build to preserve hook state.',
      );

  static const code = LintCode(
    'avoid_conditional_hooks',
    'This hook is called conditionally.',
    correctionMessage:
        'Ensure that hooks are called unconditionally in the same order on every build.',
    severity: .WARNING,
  );

  @override
  LintCode get diagnosticCode => code;

  @override
  void registerNodeProcessors(
    RuleVisitorRegistry registry,
    RuleContext context,
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
      final firstReturn = returnExpressions.isEmpty
          ? null
          : returnExpressions.reduce(
              (acc, curr) => acc.offset < curr.offset ? acc : curr,
            );

      for (final hookExpression in hookExpressions) {
        if (_isConditional(firstReturn, hookExpression, node)) {
          reportAtNode(hookExpression);
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
            type: .QUESTION_QUESTION || .AMPERSAND_AMPERSAND || .BAR_BAR,
          ),
          :final rightOperand,
        )
            when rightOperand == child =>
          true,
        AssignmentExpression(
          operator: Token(
            type: .QUESTION_QUESTION_EQ ||
                .AMPERSAND_EQ ||
                .BAR_EQ ||
                .CARET_EQ,
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
          !range.node(firstReturn).covers(range.node(node));
    }

    return isConditional(node, child: node) ||
        (firstReturn != null && isBefore(firstReturn, node));
  }
}
