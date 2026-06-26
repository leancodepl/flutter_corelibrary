import 'package:analysis_server_plugin/edit/dart/correction_producer.dart';
import 'package:analysis_server_plugin/edit/dart/dart_fix_kind_priority.dart';
import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/error/error.dart';
import 'package:analyzer_plugin/utilities/change_builder/change_builder_core.dart';
import 'package:analyzer_plugin/utilities/fixes/fixes.dart';
import 'package:analyzer_plugin/utilities/range_factory.dart';
import 'package:leancode_lint/src/type_checker.dart';

/// Warns when a BuildContext parameter is explicitly discarded using `_`.
///
/// Discarding a context causes the body to use an ancestor context instead,
/// risking incorrect theme lookups, navigation, or inherited widget reads.
class NeverDiscardBuildContext extends AnalysisRule {
  NeverDiscardBuildContext()
    : super(name: code.lowerCaseName, description: code.problemMessage);

  static const code = LintCode(
    'never_discard_build_context',
    "Don't discard BuildContext parameters.",
    correctionMessage:
        'Give the BuildContext parameter a name to avoid accidentally using an ancestor context.',
    severity: .WARNING,
  );

  @override
  LintCode get diagnosticCode => code;

  @override
  void registerNodeProcessors(
    RuleVisitorRegistry registry,
    RuleContext context,
  ) {
    registry.addFormalParameterList(this, _Visitor(this));
  }
}

class _Visitor extends SimpleAstVisitor<void> {
  _Visitor(this.rule);

  final AnalysisRule rule;

  static const _buildContextChecker = TypeChecker.fromName(
    'BuildContext',
    packageName: 'flutter',
  );

  @override
  void visitFormalParameterList(FormalParameterList node) {
    node.parameters.forEach(_checkParameter);
  }

  void _checkParameter(FormalParameter parameter) {
    final name = parameter.name;
    if (name == null || name.lexeme != '_') {
      return;
    }

    final type = parameter.declaredFragment?.element.type;
    if (type == null) {
      return;
    }

    if (_buildContextChecker.isExactlyType(type)) {
      rule.reportAtToken(name);
    }
  }
}

class RenameDiscardedBuildContextFix extends ResolvedCorrectionProducer {
  RenameDiscardedBuildContextFix({required super.context});

  @override
  FixKind get fixKind => const .new(
    'leancode_lint.fix.renameDiscardedBuildContext',
    DartFixKindPriority.standard,
    "Rename to 'context'",
  );

  @override
  CorrectionApplicability get applicability => .automatically;

  @override
  Future<void> compute(ChangeBuilder builder) async {
    await builder.addDartFileEdit(
      file,
      (builder) => builder.addSimpleReplacement(
        range.diagnostic(diagnostic!),
        'context',
      ),
    );
  }
}
