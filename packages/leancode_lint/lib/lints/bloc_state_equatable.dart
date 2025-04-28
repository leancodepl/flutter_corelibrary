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
  List<Fix> getFixes() => [AddMixin()];

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

      final isEquatableMixin = blocData.stateElement.mixins.any(
        const TypeChecker.fromName('EquatableMixin', packageName: 'equatable')
            .isExactlyType,
      );
      final isEquatable =
          const TypeChecker.fromName('Equatable', packageName: 'equatable')
              .isAssignableFrom(blocData.stateElement);

      if (!isEquatableMixin && !isEquatable) {
        reporter.atElement(
          blocData.stateElement,
          code,
          arguments: [blocData.expectedStateName],
        );
      }
    });
  }
}

class AddMixin extends DartFix {
  @override
  void run(
    CustomLintResolver resolver,
    ChangeReporter reporter,
    CustomLintContext context,
    AnalysisError analysisError,
    List<AnalysisError> others,
  ) {
    reporter
        .createChangeBuilder(message: 'Add EquatableMixin', priority: 1)
        .addDartFileEdit(
          (builder) => builder
            ..importLibrary(Uri.parse('package:equatable/equatable.dart'))
            ..addSimpleInsertion(
              analysisError.offset + analysisError.length,
              ' with EquatableMixin',
            ),
        );
  }
}
