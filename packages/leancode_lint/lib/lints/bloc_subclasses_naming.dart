import 'package:analyzer/error/error.dart' hide LintCode;
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';
import 'package:leancode_lint/helpers.dart';

class BlocSubclassesNaming extends DartLintRule {
  const BlocSubclassesNaming()
      : super(
          code: const LintCode(
            name: 'bloc_subclasses_naming',
            problemMessage: "{0}'s {1} subclasses should start with {2}",
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

      final stateBaseName = '${data.baseName}State';
      for (final subtype in data.stateElement.subclasses) {
        if (!subtype.name.startsWith(stateBaseName)) {
          reporter.atElement(
            subtype,
            code,
            arguments: [node.name.lexeme, 'state', stateBaseName],
          );
        }
      }
    });
  }
}
