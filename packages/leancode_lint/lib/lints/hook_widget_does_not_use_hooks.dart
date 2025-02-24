import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/error/error.dart';
import 'package:analyzer/error/listener.dart';
import 'package:analyzer/source/source_range.dart';
import 'package:analyzer/src/lint/linter.dart';
import 'package:leancode_lint/helpers.dart';

/// Displays warning when a `HookWidget` does not use hooks in the build method.
class HookWidgetDoesNotUseHooks extends AnalysisRule {
  HookWidgetDoesNotUseHooks()
    : super(
        name: 'hook_widget_does_not_use_hooks',
        description: 'This HookWidget does not use hooks.',
      );

  @override
  LintCode get lintCode => LintCode(
    name,
    description,
    correctionMessage: 'Convert it to a StatelessWidget',
  );

  @override
  void registerNodeProcessors(
    NodeLintRegistry registry,
    LinterContext context,
  ) {
    registry.addHookWidgetBody(this, isExactly: true, (node, diagnosticTarget) {
      // get all hook expressions from build method
      final hookExpressions = switch (node) {
        ExpressionFunctionBody(expression: final AstNode node) ||
        BlockFunctionBody(
          block: final AstNode node,
        ) => getAllInnerHookExpressions(node),
        _ => <Expression>[],
      };

      if (hookExpressions.isNotEmpty) {
        return;
      }

      reportLint(diagnosticTarget);
    });
  }

  @override
  List<Fix> getFixes() => [_ConvertHookWidgetToStatelessWidget()];
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
