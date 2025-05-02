import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/error/error.dart' hide LintCode;
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

class UseClock extends DartLintRule {
  const UseClock()
      : super(
          code: const LintCode(
            name: 'use_clock',
            problemMessage: 'Use clock.now() instead of DateTime.now().',
            errorSeverity: ErrorSeverity.WARNING,
          ),
        );

  static const _dateTime =
      TypeChecker.fromName('DateTime', packageName: 'dart:core');

  @override
  List<Fix> getFixes() => [ReplaceWithClock()];

  @override
  void run(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
  ) {
    context.registry.addInstanceCreationExpression((node) {
      if (node
          case InstanceCreationExpression(
            constructorName: ConstructorName(
              type: NamedType(:final element?),
              name: SimpleIdentifier(name: 'now'),
            )
          ) when _dateTime.isExactly(element)) {
        reporter.atNode(node, code);
      }
    });
  }
}

class ReplaceWithClock extends DartFix {
  @override
  void run(
    CustomLintResolver resolver,
    ChangeReporter reporter,
    CustomLintContext context,
    AnalysisError analysisError,
    List<AnalysisError> others,
  ) {
    reporter
        .createChangeBuilder(message: 'Replace with clock.now()', priority: 1)
        .addDartFileEdit(
          (builder) => builder
            ..importLibrary(Uri.parse('package:clock/clock.dart'))
            ..addSimpleReplacement(analysisError.sourceRange, 'clock.now()'),
        );
  }
}
