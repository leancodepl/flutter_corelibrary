import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/error/error.dart' hide LintCode;
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

class NeverDiscardBuildContext extends DartLintRule {
  const NeverDiscardBuildContext()
      : super(
          code: const LintCode(
            name: 'never_discard_build_context',
            problemMessage: "Don't discard BuildContext parameters.",
            errorSeverity: ErrorSeverity.WARNING,
          ),
        );

  static const _buildContext =
      TypeChecker.fromName('BuildContext', packageName: 'flutter');

  @override
  List<Fix> getFixes() => [RenameParameter()];

  @override
  void run(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
  ) {
    void checkParameters(FormalParameterList? parameterList) {
      for (final param in [...?parameterList?.parameters]) {
        if (param.declaredElement case final element?
            when _buildContext.isExactlyType(element.type) &&
                RegExp(r'^_+$').hasMatch(element.name)) {
          reporter.atElement(element, code);
        }
      }
    }

    context.registry.addFunctionExpression((node) {
      checkParameters(node.parameters);
    });
    context.registry.addFunctionDeclaration((node) {
      checkParameters(node.functionExpression.parameters);
    });
    context.registry.addMethodDeclaration((node) {
      checkParameters(node.parameters);
    });
  }
}

class RenameParameter extends DartFix {
  @override
  void run(
    CustomLintResolver resolver,
    ChangeReporter reporter,
    CustomLintContext context,
    AnalysisError analysisError,
    List<AnalysisError> others,
  ) {
    reporter
        .createChangeBuilder(message: 'Rename to `context`', priority: 1)
        .addDartFileEdit(
          (builder) => builder.addSimpleReplacement(
            analysisError.sourceRange,
            'context',
          ),
        );
  }
}
