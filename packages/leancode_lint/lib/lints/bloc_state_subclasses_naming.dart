import 'package:analyzer/error/error.dart' hide LintCode;
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';
import 'package:leancode_lint/helpers.dart';

class BlocStateSubclassesNaming extends DartLintRule {
  const BlocStateSubclassesNaming()
      : super(
          code: const LintCode(
            name: 'bloc_state_subclass_name',
            problemMessage:
                'State subclasses should have the base name as the prefix.',
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

      for (final subtype in data.stateElement.subclasses) {
        if (!subtype.name.startsWith('${data.baseName}State')) {
          reporter.atElement(subtype, code);
        }
      }
    });
  }
}
