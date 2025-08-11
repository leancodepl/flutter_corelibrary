import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';
import 'package:leancode_lint/helpers.dart';

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
  List<Fix> getFixes() => [ChangeWidgetNameFix('Padding')];

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
            parameter: 'padding',
            // Ignores key and child parameters because both Container and Padding have them
            ignoredParameters: const {'key', 'child'},
          )) {
        reporter.atNode(node.constructorName, code);
      }
    });
  }
}
