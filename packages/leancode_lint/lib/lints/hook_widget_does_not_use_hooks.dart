import 'package:analysis_server_plugin/edit/dart/correction_producer.dart';
import 'package:analysis_server_plugin/edit/dart/dart_fix_kind_priority.dart';
import 'package:analysis_server_plugin/src/correction/fix_generators.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/error/error.dart';
import 'package:analyzer/source/source_range.dart';
import 'package:analyzer/src/lint/linter.dart';
import 'package:analyzer_plugin/utilities/change_builder/change_builder_core.dart';
import 'package:analyzer_plugin/utilities/fixes/fixes.dart';
import 'package:leancode_lint/helpers.dart';

/// Displays warning when a `HookWidget` does not use hooks in the build method.
class HookWidgetDoesNotUseHooks extends AnalysisRule
    with AnalysisRuleWithFixes {
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
  List<ProducerGenerator> get fixes => [ConvertHookWidgetToStatelessWidget.new];
}

class ConvertHookWidgetToStatelessWidget extends ResolvedCorrectionProducer {
  ConvertHookWidgetToStatelessWidget({required super.context});

  @override
  FixKind? get fixKind => const FixKind(
    'leancode.lint.convertHookWidgetToStatelessWidget',
    DartFixKindPriority.standard,
    'Convert HookWidget to StatelessWidget',
  );

  @override
  CorrectionApplicability get applicability =>
      CorrectionApplicability.singleLocation;

  @override
  Future<void> compute(ChangeBuilder builder) async {
    await builder.addDartFileEdit(
      file,
      (builder) => builder.addSimpleReplacement(
        SourceRange(errorOffset!, errorLength!),
        'StatelessWidget',
      ),
    );
  }
}
