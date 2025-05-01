import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/error/error.dart' hide LintCode;
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';
import 'package:leancode_lint/helpers.dart';

class BlocClassModifiers extends DartLintRule {
  const BlocClassModifiers()
      : super(
          code: const LintCode(
            name: 'bloc_class_modifiers',
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
      final data = maybeBlocData(node);
      if (data == null) {
        return;
      }

      if (!data.inSamePackage) {
        return;
      }

      void checkHierarchy(ClassElement clazz) {
        final subclasses = clazz.subclasses..forEach(checkHierarchy);

        if (subclasses.isEmpty) {
          if (!clazz.isFinal) {
            reporter.atElement(
              clazz,
              code,
              arguments: [data.stateElement.name, 'final'],
              data: 'final',
            );
          }
        } else {
          if (!clazz.isSealed) {
            reporter.atElement(
              clazz,
              code,
              arguments: [data.stateElement.name, 'sealed'],
              data: 'sealed',
            );
          }
        }
      }

      checkHierarchy(data.stateElement);

      if (data.eventElement case final eventElement?) {
        checkHierarchy(eventElement);
      }

      if (data.presentationEventElement case final presentationEventElement?) {
        checkHierarchy(presentationEventElement);
      }
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
