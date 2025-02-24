import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/error/error.dart';
import 'package:analyzer/src/lint/linter.dart';

/// Enforces that a catch clause has correctly named variable bindings:
/// - if it's a catch-all, the exception should be named `err` and the stacktrace `st`
/// - if it's a typed catch, the stacktrace has to be named `st`
class CatchParameterNames extends AnalysisRule {
  CatchParameterNames()
    : super(
        name: 'catch_parameter_names',
        description:
            'Enforces that a catch clause has correctly named variable bindings.',
      );

  @override
  LintCode get lintCode => LintCode(
    name,
    'Parameter name for the {0} is non-standard.',
    correctionMessage: 'Rename the parameter to {1}`.',
  );

  @override
  void registerNodeProcessors(
    NodeLintRegistry registry,
    LinterContext context,
  ) {
    registry.addCatchClause(this, _Visitor(this, context));
  }
}

class _Visitor extends SimpleAstVisitor<void> {
  _Visitor(this.rule, this.context);

  final LintRule rule;
  final LinterContext context;

  @override
  void visitCatchClause(CatchClause node) {
    // not a typed catch `} on TypeName {`
    if (node.exceptionType == null) {
      _checkParameter(node.exceptionParameter, _CatchClauseParameter.exception);
    }

    _checkParameter(node.stackTraceParameter, _CatchClauseParameter.stackTrace);
  }

  void _checkParameter(
    CatchClauseParameter? node,
    _CatchClauseParameter param,
  ) {
    if (node != null &&
        !{'_', param.preferredName}.contains(node.name.lexeme)) {
      rule.reportLint(node, arguments: [param.name, param.preferredName]);
    }
  }
}

enum _CatchClauseParameter {
  exception,
  stackTrace;

  String get preferredName => switch (this) {
    exception => 'err',
    stackTrace => 'st',
  };
}
