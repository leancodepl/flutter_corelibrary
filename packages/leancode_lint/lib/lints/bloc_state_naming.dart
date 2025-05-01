import 'package:analyzer/error/error.dart' hide LintCode;
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';
import 'package:leancode_lint/helpers.dart';

class BlocStateNaming extends DartLintRule {
  const BlocStateNaming()
      : super(
          code: const LintCode(
            name: 'bloc_state_base_name',
            problemMessage: "The name of {0}'s state should be {1}.",
            errorSeverity: ErrorSeverity.WARNING,
          ),
        );

  @override
  void run(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
  ) {
    context.registry.addClassDeclaration((node) {
      final data = maybeBlocData(node);
      if (data == null) {
        return;
      }

      if (!data.inSamePackage) {
        return;
      }

      final expectedName = '${data.baseName}State';

      if (data.stateElement.name != expectedName) {
        reporter.atToken(
          node.name,
          code,
          arguments: [node.name.lexeme, expectedName],
        );
      }
    });
  }
}
