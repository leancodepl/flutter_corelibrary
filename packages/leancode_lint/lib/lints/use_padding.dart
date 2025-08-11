import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/error/error.dart' as error;
import 'package:analyzer/error/listener.dart';
import 'package:analyzer_plugin/utilities/range_factory.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';
import 'package:leancode_lint/helpers.dart';
import 'package:leancode_lint/utils.dart';

class UsePadding extends DartLintRule {
  const UsePadding()
    : super(
        code: const LintCode(
          name: ruleName,
          problemMessage:
              'Use Padding widget instead of the Container widget with only the padding parameter',
        ),
      );

  static const ruleName = 'use_padding';

  @override
  List<Fix> getFixes() => [_UsePaddingFix()];

  @override
  void run(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
  ) {
    context.registry.addInstanceCreationExpression((node) {
      if (isExpressionExactlyType(node, 'Container', 'flutter') &&
          isInstanceCreationExpressionOnlyUsingParameter(
            node,
            parameter: 'margin',
            // Ignores key and child parameters because both Container and Padding have them
            ignoredParameters: const {'key', 'child'},
          )) {
        reporter.atNode(
          node.constructorName,
          code,
          data: _findMarginParameterLabel(node),
        );
      }
    });
  }

  SimpleIdentifier? _findMarginParameterLabel(
    InstanceCreationExpression node,
  ) => node.argumentList.arguments
      .whereType<NamedExpression>()
      .firstWhereOrNull((e) => e.name.label.name == 'margin')
      ?.name
      .label;
}

class _UsePaddingFix extends DartFix {
  @override
  void run(
    CustomLintResolver resolver,
    ChangeReporter reporter,
    CustomLintContext context,
    error.AnalysisError analysisError,
    List<error.AnalysisError> errors,
  ) {
    if (analysisError.data case final SimpleIdentifier margin?) {
      reporter
          .createChangeBuilder(message: 'Replace with Padding', priority: 1)
          .addDartFileEdit((builder) {
            builder
              ..addSimpleReplacement(analysisError.sourceRange, 'Padding')
              ..addSimpleReplacement(range.node(margin), 'padding');
          });
    }
  }
}
