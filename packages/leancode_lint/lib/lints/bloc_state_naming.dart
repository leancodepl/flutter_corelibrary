import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/error/error.dart' hide LintCode;
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';
import 'package:leancode_lint/helpers.dart';

class BlocStateNaming extends DartLintRule {
  const BlocStateNaming() : super(code: stateNameCode);

  static const stateNameCode = LintCode(
    name: 'bloc_state_base_name',
    problemMessage: "The name of {0}'s state should be {1}.",
    errorSeverity: ErrorSeverity.WARNING,
  );

  static const stateSealedCode = LintCode(
    name: 'bloc_state_sealed',
    problemMessage: 'The class {0} should be sealed.',
    errorSeverity: ErrorSeverity.WARNING,
  );

  static const stateFinalCode = LintCode(
    name: 'bloc_state_final',
    problemMessage: 'The class {0} should be final.',
    errorSeverity: ErrorSeverity.WARNING,
  );

  static const subclassNameCode = LintCode(
    name: 'bloc_state_subclass_name',
    problemMessage: 'State subclasses should have the base name as the prefix.',
    errorSeverity: ErrorSeverity.WARNING,
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

      final (
        :blocElement,
        :expectedStateName,
        :stateElement,
        :stateSubclasses,
      ) = blocData;

      final statePackage = stateElement.package;
      final blocPackage = blocElement.package;

      if (statePackage == null ||
          blocPackage == null ||
          statePackage != blocPackage) {
        return;
      }

      if (stateElement.name != expectedStateName) {
        reporter.atToken(
          node.name,
          stateNameCode,
          arguments: [node.name.lexeme, expectedStateName],
        );
      }

      if (stateSubclasses.isEmpty) {
        if (!stateElement.isFinal) {
          reporter.atElement(
            stateElement,
            stateFinalCode,
            arguments: [expectedStateName],
          );
        }
      } else {
        if (!stateElement.isSealed) {
          reporter.atElement(
            stateElement,
            stateSealedCode,
            arguments: [expectedStateName],
          );
        }
      }

      for (final subtype in stateSubclasses) {
        if (!subtype.name.startsWith(expectedStateName)) {
          reporter.atElement(subtype, subclassNameCode);
        }
      }
    });
  }
}

extension on Element {
  String? get package {
    final uri = library?.definingCompilationUnit.source.uri;
    if (uri == null || uri.scheme != 'package') {
      return null;
    }

    return uri.pathSegments.first;
  }
}
