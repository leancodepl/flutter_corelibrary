import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/error/error.dart' hide LintCode;
import 'package:analyzer/error/listener.dart';
import 'package:analyzer/source/source_range.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';
import 'package:leancode_lint/helpers.dart';

/// Displays warning when a `HookWidget` does not use hooks in the build method.
class HookWidgetDoesNotUseHooks extends DartLintRule {
  HookWidgetDoesNotUseHooks() : super(code: _getLintCode());

  static const ruleName = 'hook_widget_does_not_use_hooks';

  @override
  void run(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
  ) {
    context.registry.addHookWidgetBody(
      isExactly: true,
      (node, diagnosticTarget) {
        // get all hook expressions from build method
        final hookExpressions = switch (node) {
          ExpressionFunctionBody(expression: final AstNode node) ||
          BlockFunctionBody(block: final AstNode node) =>
            getAllInnerHookExpressions(node),
          _ => <Expression>[],
        };

        if (hookExpressions.isNotEmpty) {
          return;
        }

        reporter.atNode(diagnosticTarget, _getLintCode());
      },
    );
  }

  @override
  List<Fix> getFixes() => [
        _ConvertHookWidgetToStatelessWidget(),
      ];

  static LintCode _getLintCode() => const LintCode(
        name: ruleName,
        problemMessage: 'This HookWidget does not use hooks.',
        correctionMessage: 'Convert it to a StatelessWidget',
        errorSeverity: ErrorSeverity.WARNING,
      );
}

class _ConvertHookWidgetToStatelessWidget extends DartFix {
  @override
  void run(
    CustomLintResolver resolver,
    ChangeReporter reporter,
    CustomLintContext context,
    AnalysisError analysisError,
    List<AnalysisError> others,
  ) {
    reporter
        .createChangeBuilder(
          message: 'Convert HookWidget to StatelessWidget',
          priority: 1,
        )
        .addDartFileEdit(
          (builder) => builder.addSimpleReplacement(
            SourceRange(analysisError.offset, analysisError.length),
            'StatelessWidget',
          ),
        );
  }
}
