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
    context.registry.addBloc((node, data) {
      if (!data.inSamePackage) {
        return;
      }

      final elements = {
        'state': {data.stateElement, ...data.stateElement.subclasses},
        if (data.eventElement case final element?)
          'event': {element, ...element.subclasses},
        if (data.presentationEventElement case final element?)
          'presentation event': {element, ...element.subclasses},
      };

      for (final MapEntry(key: type, value: classes) in elements.entries) {
        for (final clazz in classes) {
          if (clazz.unnamedConstructor case final unnamedConstructor?
              when !unnamedConstructor.isConst) {
            reporter.atElement(
              unnamedConstructor.isSynthetic ? clazz : unnamedConstructor,
              code,
              arguments: [type, clazz.name],
            );
          }
        }
      }
    });
  }
}
