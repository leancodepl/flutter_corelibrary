import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';
import 'package:leancode_lint/helpers.dart';

class UseAlign extends DartLintRule {
  const UseAlign()
    : super(
        code: const LintCode(
          name: ruleName,
          problemMessage:
              'Use Align widget instead of the Container widget with only the alignment parameter',
        ),
      );

  static const ruleName = 'use_align';

  @override
  List<Fix> getFixes() => [ChangeWidgetNameFix('Align')];

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
            parameter: 'alignment',
            // Ignores key and child parameters because both Container and Align have them
            ignoredParameters: const {'key', 'child'},
          )) {
        reporter.atNode(node.constructorName, code);
      }
    });
  }
}
