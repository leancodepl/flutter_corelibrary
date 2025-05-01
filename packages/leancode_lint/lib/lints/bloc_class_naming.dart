import 'package:analyzer/error/error.dart' hide LintCode;
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';
import 'package:leancode_lint/helpers.dart';

class BlocClassNaming extends DartLintRule {
  const BlocClassNaming()
      : super(
          code: const LintCode(
            name: 'bloc_class_naming',
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
    context.registry.addClassDeclaration((node) {
      final data = maybeBlocData(node);
      if (data == null) {
        return;
      }

      if (!data.inSamePackage) {
        return;
      }

      final expectedStateName = '${data.baseName}State';
      final expectedEventName = '${data.baseName}Event';
      final expectedPresentationEventName = expectedEventName;

      if (data.stateElement.name != expectedStateName) {
        reporter.atElement(
          data.stateElement,
          code,
          arguments: [node.name.lexeme, 'state', expectedStateName],
        );
      }

      if (data.eventElement case final eventElement?
          when data.eventElement?.name != expectedEventName) {
        reporter.atElement(
          eventElement,
          code,
          arguments: [node.name.lexeme, 'event', expectedEventName],
        );
      }

      if (data.presentationEventElement case final presentationEventElement?
          when data.presentationEventElement?.name !=
              expectedPresentationEventName) {
        reporter.atElement(
          presentationEventElement,
          code,
          arguments: [
            node.name.lexeme,
            'presentation event',
            expectedPresentationEventName,
          ],
        );
      }
    });
  }
}
