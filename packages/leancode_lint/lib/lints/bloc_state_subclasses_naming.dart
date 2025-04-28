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
      final blocData = maybeBlocData(node);
      if (blocData == null) {
        return;
      }

      if (!areInSamePackage(blocData.stateElement, blocData.blocElement)) {
        return;
      }

      for (final subtype in blocData.stateSubclasses) {
        if (!subtype.name.startsWith(blocData.expectedStateName)) {
          reporter.atElement(subtype, code);
        }
      }
    });
  }
}
