import 'package:analyzer/dart/element/element2.dart';
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
    context.registry.addBloc((node, data) {
      void check(InterfaceElement2? element, String type) {
        if (element != null && inSameFile(data.blocElement, element)) {
          for (final subtype in element.subclasses) {
            if (!subtype.displayName.startsWith(element.displayName)) {
              reporter.atElement2(
                subtype,
                code,
                arguments: [node.name.lexeme, type, element.displayName],
              );
            }
          }
        }
      }

      check(data.stateElement, 'state');
      check(data.eventElement, 'event');
      check(data.presentationEventElement, 'presentation event');
    });
  }
}
