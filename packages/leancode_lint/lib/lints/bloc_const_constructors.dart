import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/error/error.dart' hide LintCode;
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';
import 'package:leancode_lint/helpers.dart';

class BlocConstConstructors extends DartLintRule {
  const BlocConstConstructors()
      : super(
          code: const LintCode(
            name: 'bloc_const_constructors',
            problemMessage:
                'The {0} class {1} should have an unnamed const constructor.',
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

      void checkClass(ClassElement clazz, String type) {
        if (clazz.unnamedConstructor case final unnamedConstructor?
            when !unnamedConstructor.isConst) {
          reporter.atElement(
            unnamedConstructor.isSynthetic ? clazz : unnamedConstructor,
            code,
            arguments: [type, clazz.name],
          );
        }
      }

      for (final clazz in {
        data.stateElement,
        ...data.stateElement.subclasses,
      }) {
        checkClass(clazz, 'state');
      }

      if (data.eventElement case final eventElement?) {
        for (final clazz in {
          eventElement,
          ...eventElement.subclasses,
        }) {
          checkClass(clazz, 'event');
        }
      }

      if (data.presentationEventElement case final presentationEventElement?) {
        for (final clazz in {
          presentationEventElement,
          ...presentationEventElement.subclasses,
        }) {
          checkClass(clazz, 'presentation event');
        }
      }
    });
  }
}
