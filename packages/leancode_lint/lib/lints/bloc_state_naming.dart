import 'package:analyzer/error/error.dart' hide LintCode;
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';
import 'package:leancode_lint/helpers.dart';

class BlocStateNaming extends DartLintRule {
  const BlocStateNaming() : super(code: stateNameCode);

  static const stateNameCode = LintCode(
    name: 'bloc_state_base_name',
    problemMessage: "The name of {0}'s state should be {1}.",
    errorSeverity: ErrorSeverity.WARNING,
  );

  @override
  void run(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
  ) {
    context.registry.addClassDeclaration((node) {
      final blocData = maybeBlocData(node);
      if (blocData == null) {
        return;
      }

      final (:blocElement, :expectedStateName, :stateElement) = blocData;

      if (!areInSamePackage(stateElement, blocElement)) {
        return;
      }

      if (stateElement.name != expectedStateName) {
        reporter.atToken(
          node.name,
          stateNameCode,
          arguments: [node.name.lexeme, expectedStateName],
        );
      }
    });
  }
}
