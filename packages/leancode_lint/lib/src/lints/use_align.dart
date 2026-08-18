import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/error/error.dart';
import 'package:leancode_lint/src/helpers.dart';

class UseAlign() extends AnalysisRule {
  this : super(name: code.lowerCaseName, description: code.problemMessage);

  static const code = LintCode(
    'use_align',
    'Use Align widget instead of the Container widget with only the alignment parameter.',
    severity: .WARNING,
  );

  @override
  LintCode get diagnosticCode => code;

  @override
  void registerNodeProcessors(
    RuleVisitorRegistry registry,
    RuleContext context,
  ) {
    registry.addInstanceCreationExpression(this, _Visitor(this, context));
  }
}

class _Visitor(final AnalysisRule rule, final RuleContext context)
    extends SimpleAstVisitor<void> {
  @override
  void visitInstanceCreationExpression(InstanceCreationExpression node) {
    if (isExpressionExactlyType(node, 'Container', 'flutter') &&
        isInstanceCreationExpressionOnlyUsingParameter(
          node,
          parameter: 'alignment',
          // Ignores key and child parameters because both Container and Align have them
          ignoredParameters: const {'key', 'child'},
        )) {
      rule.reportAtNode(node.constructorName);
    }
  }
}

class UseAlignFix({required super.context}) extends ChangeWidgetNameFix {
  this : super(widgetName: 'Align');
}
