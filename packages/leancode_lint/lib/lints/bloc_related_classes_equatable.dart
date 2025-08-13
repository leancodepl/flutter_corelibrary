import 'package:analyzer/dart/element/element2.dart';
import 'package:analyzer/error/error.dart' hide LintCode;
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';
import 'package:leancode_lint/common_type_checkers.dart';
import 'package:leancode_lint/helpers.dart';

class BlocRelatedClassesEquatable extends DartLintRule {
  const BlocRelatedClassesEquatable()
    : super(
        code: const LintCode(
          name: 'bloc_related_classes_equatable',
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
    context.registry.addBloc((node, data) {
      void check(InterfaceElement2? element) {
        if (element is! ClassElement2 ||
            !inSameFile(data.blocElement, element)) {
          return;
        }

        final isEquatableMixin = element.mixins.any(
          TypeCheckers.equatableMixin.isExactlyType,
        );
        final isEquatable = TypeCheckers.equatable.isAssignableFromType(
          element.thisType,
        );

        if (!isEquatableMixin && !isEquatable) {
          reporter.atElement2(element, code, arguments: [element.displayName]);
        }
      }

      check(data.stateElement);
      check(data.eventElement);
      check(data.presentationEventElement);
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
