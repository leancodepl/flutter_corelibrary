import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/error/error.dart';
import 'package:leancode_lint/config.dart';

/// Enforces consistent names for `catch` clause parameters.
///
/// By default:
/// - exception parameter → `err`
/// - stack trace parameter → `st`
///
/// These names can be customized via `LeancodeLintConfig.catchParameterNames`.
///
/// Untyped `catch` clauses check both parameters, while typed `on T catch`
/// clauses only enforce the stack trace name.
class CatchParameterNames extends AnalysisRule {
  CatchParameterNames({required this.config})
    : super(name: code.lowerCaseName, description: code.problemMessage);

  final LeancodeLintConfig config;

  static const code = LintCode(
    'catch_parameter_names',
    'Parameter name for the {0} is non-standard.',
    correctionMessage: 'Rename the parameter to `{1}`.',
    severity: .WARNING,
  );

  @override
  LintCode get diagnosticCode => code;

  @override
  void registerNodeProcessors(
    RuleVisitorRegistry registry,
    RuleContext context,
  ) {
    registry.addCatchClause(this, _Visitor(this, context, config));
  }
}

class _Visitor extends SimpleAstVisitor<void> {
  _Visitor(this.rule, this.context, this.config);

  final AnalysisRule rule;
  final RuleContext context;
  final LeancodeLintConfig config;

  @override
  void visitCatchClause(CatchClause node) {
    // not a typed catch `} on TypeName {`
    if (node.exceptionType == null) {
      _checkParameter(node.exceptionParameter, .exception);
    }

    _checkParameter(node.stackTraceParameter, .stackTrace);
  }

  void _checkParameter(
    CatchClauseParameter? node,
    _CatchClauseParameter param,
  ) {
    if (node == null) {
      return;
    }

    final actualName = node.name.lexeme;
    final preferred = param.preferredName(config);

    if (actualName == '_' || actualName == preferred) {
      return;
    }

    rule.reportAtNode(node, arguments: [param.name, preferred]);
  }
}

enum _CatchClauseParameter {
  exception,
  stackTrace;

  String preferredName(LeancodeLintConfig config) => switch (this) {
    exception => config.catchParameterNames.exception,
    stackTrace => config.catchParameterNames.stackTrace,
  };
}
