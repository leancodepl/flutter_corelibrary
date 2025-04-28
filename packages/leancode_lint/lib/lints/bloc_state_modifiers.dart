import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/error/error.dart' hide LintCode;
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';
import 'package:leancode_lint/helpers.dart';

class BlocStateModifiers extends DartLintRule {
  const BlocStateModifiers()
      : super(
          code: const LintCode(
            name: 'bloc_state_modifiers',
            problemMessage: 'The class {0} should be {1}.',
            errorSeverity: ErrorSeverity.WARNING,
          ),
        );

  @override
  List<Fix> getFixes() => [AddModifier()];

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

      final (:blocElement, :expectedStateName, :stateElement) = blocData;

      if (!areInSamePackage(stateElement, blocElement)) {
        return;
      }

      void checkHierarchy(ClassElement clazz) {
        final subclasses = clazz.subclasses..forEach(checkHierarchy);

        if (subclasses.isEmpty) {
          if (!clazz.isFinal) {
            reporter.atElement(
              clazz,
              code,
              arguments: [expectedStateName, 'final'],
              data: 'final',
            );
          }
        } else {
          if (!clazz.isSealed) {
            reporter.atElement(
              clazz,
              code,
              arguments: [expectedStateName, 'sealed'],
              data: 'sealed',
            );
          }
        }
      }

      checkHierarchy(stateElement);
    });
  }
}

class AddModifier extends DartFix {
  @override
  void run(
    CustomLintResolver resolver,
    ChangeReporter reporter,
    CustomLintContext context,
    AnalysisError analysisError,
    List<AnalysisError> others,
  ) {
    final missingModifier = analysisError.data! as String;

    reporter
        .createChangeBuilder(
      message: 'Add $missingModifier modifier',
      priority: 1,
    )
        .addDartFileEdit((builder) {
      final lineStart = resolver.lineInfo.getOffsetOfLine(
        resolver.lineInfo.getLocation(analysisError.offset).lineNumber,
      );

      builder.addSimpleInsertion(lineStart, '$missingModifier ');
    });
  }
}
