import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/error/error.dart' hide LintCode;
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';
import 'package:leancode_lint/helpers.dart';

class BlocClassModifiers extends DartLintRule {
  const BlocClassModifiers()
    : super(
        code: const LintCode(
          name: 'bloc_class_modifiers',
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
    context.registry.addBloc((node, data) {
      void checkHierarchy(InterfaceElement? element) {
        if (element is! ClassElement ||
            !inSameFile(data.blocElement, element)) {
          return;
        }

        final subclasses = element.subclasses;

        if (subclasses.isNotEmpty) {
          if (!element.isSealed) {
            reporter.atElement(
              element,
              code,
              arguments: [element.name, 'sealed'],
              data: 'sealed',
            );
          }
        } else {
          if (!element.isFinal) {
            reporter.atElement(
              element,
              code,
              arguments: [element.name, 'final'],
              data: 'final',
            );
          }
        }

        subclasses.forEach(checkHierarchy);
      }

      checkHierarchy(data.stateElement);
      checkHierarchy(data.eventElement);
      checkHierarchy(data.presentationEventElement);
    });
  }
}
