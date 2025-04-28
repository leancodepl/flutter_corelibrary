import 'package:analyzer/error/error.dart' hide LintCode;
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';
import 'package:leancode_lint/helpers.dart';

class BlocStateEquatable extends DartLintRule {
  const BlocStateEquatable()
      : super(
          code: const LintCode(
            name: 'bloc_state_equatable',
            problemMessage: 'The class {0} should mix in EquatableMixin.',
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

      final isEquatableMixin = blocData.stateElement.mixins.any(
        const TypeChecker.fromName('EquatableMixin', packageName: 'equatable')
            .isExactlyType,
      );

      if (!isEquatableMixin) {
        reporter.atElement(
          blocData.stateElement,
          code,
          arguments: [blocData.expectedStateName],
        );
      }
    });
  }
}
