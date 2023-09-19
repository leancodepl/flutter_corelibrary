import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/error/error.dart';
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

/// Enforces that a catch clause has correctly named variable bindings:
/// - if it's a catch-all, the exception should be named `err` and the stacktrace `st`
/// - if it's a typed catch, the stacktrace has to be named `st`
class CatchParameterNames extends DartLintRule {
  CatchParameterNames()
      : super(code: _createCode(_CatchClauseParameter.exception));

  static LintCode _createCode(_CatchClauseParameter param) => LintCode(
        name: 'catch_parameter_names',
        problemMessage: 'Parameter name for the ${param.name} is non-standard.',
        correctionMessage: 'Rename the parameter to `${param.preferredName}`.',
        errorSeverity: ErrorSeverity.WARNING,
      );

  @override
  void run(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
  ) {
    context.registry.addCatchClause((node) {
      // not a typed catch `} on TypeName {`
      if (node.exceptionType == null) {
        _checkParameter(
          node.exceptionParameter,
          _CatchClauseParameter.exception,
          reporter,
        );
      }

      _checkParameter(
        node.stackTraceParameter,
        _CatchClauseParameter.stackTrace,
        reporter,
      );
    });
  }

  void _checkParameter(
    CatchClauseParameter? node,
    _CatchClauseParameter param,
    ErrorReporter reporter,
  ) {
    if (node != null &&
        !{'_', param.preferredName}.contains(node.name.lexeme)) {
      reporter.reportErrorForNode(
        _createCode(param),
        node,
      );
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
