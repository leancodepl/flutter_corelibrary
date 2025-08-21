import 'package:analysis_server_plugin/src/correction/fix_generators.dart';
import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/error/error.dart';
import 'package:leancode_lint/helpers.dart';

class UseAlign extends AnalysisRule with AnalysisRuleWithFixes {
  UseAlign()
    : super(
        name: 'use_align',
        description:
            'Use Align widget instead of the Container widget with only the alignment parameter',
      );

  @override
  LintCode get diagnosticCode =>
      LintCode(name, description, correctionMessage: 'Replace with Align');

  @override
  List<ProducerGenerator> get fixes => [
    ChangeWidgetNameFix.producerGeneratorFor('Align'),
  ];

  @override
  void registerNodeProcessors(
    RuleVisitorRegistry registry,
    RuleContext context,
  ) {
    registry.addInstanceCreationExpression(this, _Visitor(this, context));
  }
}

class _Visitor extends SimpleAstVisitor<void> {
  _Visitor(this.rule, this.context);

  final AnalysisRule rule;
  final RuleContext context;

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
