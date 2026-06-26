import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:analyzer/error/error.dart';

class AvoidCatchError extends AnalysisRule {
  AvoidCatchError()
    : super(name: code.lowerCaseName, description: code.problemMessage);

  static const code = LintCode(
    'avoid_catch_error',
    'Avoid using Future.catchError.',
    correctionMessage: 'Use async/await with try/catch instead.',
    severity: .WARNING,
  );

  @override
  LintCode get diagnosticCode => code;

  @override
  void registerNodeProcessors(
    RuleVisitorRegistry registry,
    RuleContext context,
  ) {
    registry.addMethodInvocation(this, _Visitor(this, context));
  }
}

class _Visitor extends SimpleAstVisitor<void> {
  _Visitor(this.rule, this.context);

  final AnalysisRule rule;
  final RuleContext context;

  @override
  void visitMethodInvocation(MethodInvocation node) {
    if (node.methodName case SimpleIdentifier(
      name: 'catchError',
      element: Element(
        baseElement: MethodElement(
          enclosingElement: InterfaceElement(
            thisType: InterfaceType(isDartAsyncFuture: true),
          ),
        ),
      ),
    )) {
      rule.reportAtNode(node.methodName);
    }
  }
}
