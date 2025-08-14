import 'package:analyzer/dart/element/element2.dart';
import 'package:analyzer/error/error.dart' hide LintCode;
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';
import 'package:leancode_lint/helpers.dart';

class BlocRelatedClassNaming extends DartLintRule {
  const BlocRelatedClassNaming()
    : super(
        code: const LintCode(
          name: 'bloc_related_class_naming',
          problemMessage: "The name of {0}'s {1} should be {2}.",
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
      void checkClass(InterfaceElement2? element, String type, String suffix) {
        final expectedName = '${data.baseName}$suffix';
        if (element != null &&
            element.displayName != expectedName &&
            inSameFile(data.blocElement, element)) {
          reporter.atElement2(
            element,
            code,
            arguments: [node.name.lexeme, type, expectedName],
          );
        }
      }

      checkClass(data.stateElement, 'state', 'State');
      checkClass(data.eventElement, 'event', 'Event');
      checkClass(
        data.presentationEventElement,
        'presentation event',
        data.eventElement == null ? 'Event' : 'PresentationEvent',
      );
    });
  }
}
