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
              'The class {0} should have an unnamed const constructor.',
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
      final elements = {
        for (final element in [
          data.stateElement,
          data.eventElement,
          data.presentationEventElement,
        ])
          if (element != null) ...{element, ...element.subclasses},
      };

      for (final element in elements) {
        if (element.unnamedConstructor2 case final unnamedConstructor?
            when !unnamedConstructor.isConst &&
                inSameFile(data.blocElement, element)) {
          if (unnamedConstructor.isSynthetic) {
            reporter.atElement2(
              element,
              code,
              arguments: [element.displayName],
            );
          } else {
            reporter.atOffset(
              offset: unnamedConstructor.firstFragment.typeNameOffset!,
              length: unnamedConstructor.firstFragment.typeName!.length,
              errorCode: code,
              arguments: [element.displayName],
            );
          }
        }
      }
    });
  }
}
