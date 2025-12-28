import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/error/error.dart' hide LintCode;
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

final class CatchParameterNamesConfig {
  const CatchParameterNamesConfig({
    required this.exceptionName,
    required this.stackTraceName,
  });

  factory CatchParameterNamesConfig.fromConfig(Map<String, Object?> json) {
    return CatchParameterNamesConfig(
      exceptionName: json['exception'] as String? ?? 'err',
      stackTraceName: json['stack_trace'] as String? ?? 'st',
    );
  }

  final String exceptionName;
  final String stackTraceName;

  String preferredName(_CatchClauseParameter param) => switch (param) {
    _CatchClauseParameter.exception => exceptionName,
    _CatchClauseParameter.stackTrace => stackTraceName,
  };
}

/// Enforces that a catch clause has correctly named variable bindings:
/// - if it's a catch-all, the exception should be named `err` and the stacktrace `st`
/// - if it's a typed catch, the stacktrace has to be named `st`
class CatchParameterNames extends DartLintRule {
  const CatchParameterNames({required this.config})
    : super(
        code: const LintCode(
          name: ruleName,
          problemMessage: 'Parameter name for the {0} is non-standard.',
          correctionMessage: 'Rename the parameter to `{1}`.',
          errorSeverity: DiagnosticSeverity.WARNING,
        ),
      );

  CatchParameterNames.fromConfigs(CustomLintConfigs configs)
      : this(
    config: CatchParameterNamesConfig.fromConfig(
      configs.rules[ruleName]?.json ?? {},
    ),
  );

  final CatchParameterNamesConfig config;

  static const ruleName = 'catch_parameter_names';

  @override
  void run(
    CustomLintResolver resolver,
    DiagnosticReporter reporter,
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
    DiagnosticReporter reporter,
  ) {
    if (node == null) {
      return;
    }

    final actualName = node.name.lexeme;
    final preferred = config.preferredName(param);

    // accept underscore or the preferred name
    if (actualName == '_' || actualName == preferred) {
      return;
    }

    reporter.atNode(node, code, arguments: [param.name, preferred]);
  }
}

enum _CatchClauseParameter {
  exception,
  stackTrace,
}
