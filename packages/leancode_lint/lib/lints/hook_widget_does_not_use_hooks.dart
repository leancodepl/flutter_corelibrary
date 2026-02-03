import 'package:analysis_server_plugin/edit/dart/correction_producer.dart';
import 'package:analysis_server_plugin/edit/dart/dart_fix_kind_priority.dart';
import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/error/error.dart';
import 'package:analyzer_plugin/utilities/change_builder/change_builder_core.dart';
import 'package:analyzer_plugin/utilities/fixes/fixes.dart';
import 'package:analyzer_plugin/utilities/range_factory.dart';
import 'package:leancode_lint/helpers.dart';

/// Displays warning when a `HookWidget` does not use hooks in the build method.
class HookWidgetDoesNotUseHooks extends AnalysisRule {
  HookWidgetDoesNotUseHooks()
    : super(name: code.lowerCaseName, description: code.problemMessage);

  static const code = LintCode(
    'hook_widget_does_not_use_hooks',
    'This HookWidget does not use hooks.',
    correctionMessage: 'Convert it to a StatelessWidget.',
    severity: .WARNING,
  );

  @override
  LintCode get diagnosticCode => code;

  @override
  void registerNodeProcessors(
    RuleVisitorRegistry registry,
    RuleContext context,
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

      reportAtNode(diagnosticTarget);
    });
  }
}

class ConvertHookWidgetToStatelessWidget extends ResolvedCorrectionProducer {
  ConvertHookWidgetToStatelessWidget({required super.context});

  @override
  FixKind? get fixKind => const FixKind(
    'leancode_lint.fix.convertHookWidgetToStatelessWidget',
    DartFixKindPriority.standard,
    'Convert HookWidget to StatelessWidget',
  );

  @override
  CorrectionApplicability get applicability => .automatically;

  @override
  Future<void> compute(ChangeBuilder builder) async {
    await builder.addDartFileEdit(
      file,
      (builder) => builder.addSimpleReplacement(
        range.diagnostic(diagnostic!),
        'StatelessWidget',
      ),
    );
  }
}
