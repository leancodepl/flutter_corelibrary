import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/error/error.dart' hide LintCode;
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';
import 'package:leancode_lint/helpers.dart';

class BlocStateModifiers extends DartLintRule {
  const BlocStateModifiers()
      : super(
          code: const LintCode(
            name: 'bloc_state_modifiers',
            problemMessage: 'The class {0} should be {1}.',
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

      final (:blocElement, :expectedStateName, :stateElement) = blocData;

      if (!areInSamePackage(stateElement, blocElement)) {
        return;
      }

      void checkHierarchy(ClassElement clazz) {
        final subclasses = clazz.subclasses..forEach(checkHierarchy);

        if (subclasses.isEmpty) {
          if (!clazz.isFinal) {
            reporter.atElement(
              clazz,
              code,
              arguments: [expectedStateName, 'final'],
            );
          }
        } else {
          if (!clazz.isSealed) {
            reporter.atElement(
              clazz,
              code,
              arguments: [expectedStateName, 'sealed'],
            );
          }
        }
      }

      checkHierarchy(stateElement);
    });
  }
}
