import 'package:analysis_server_plugin/edit/dart/correction_producer.dart';
import 'package:analysis_server_plugin/edit/dart/dart_fix_kind_priority.dart';
import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/error/error.dart';
import 'package:analyzer/source/source_range.dart';
import 'package:analyzer_plugin/utilities/change_builder/change_builder_core.dart';
import 'package:analyzer_plugin/utilities/fixes/fixes.dart';
import 'package:analyzer_plugin/utilities/range_factory.dart';
import 'package:leancode_lint/helpers.dart';
import 'package:leancode_lint/utils.dart';

class UsePadding extends AnalysisRule {
  UsePadding()
    : super(
        name: 'use_padding',
        description:
            'Use Padding widget instead of the Container widget with only the margin parameter',
      );

  @override
  LintCode get diagnosticCode => LintCode(
    name,
    description,
    correctionMessage: 'Replace with Padding',
    severity: DiagnosticSeverity.WARNING,
  );

  @override
  void registerNodeProcessors(
    RuleVisitorRegistry registry,
    RuleContext context,
  ) {
    registry.addInstanceCreationExpression(this, _Visitor(this, context));
  }
}

final _ruleData = Expando<SimpleIdentifier>();

class _Visitor extends SimpleAstVisitor<void> {
  _Visitor(this.rule, this.context);

  final AnalysisRule rule;
  final RuleContext context;

  @override
  void visitInstanceCreationExpression(InstanceCreationExpression node) {
    if (isExpressionExactlyType(node, 'Container', 'flutter') &&
        isInstanceCreationExpressionOnlyUsingParameter(
          node,
          parameter: 'margin',
          // Ignores key and child parameters because both Container and Padding have them
          ignoredParameters: const {'key', 'child'},
        )) {
      final diagnostic = context.definingUnit.diagnosticReporter.atNode(
        node.constructorName,
        rule.diagnosticCode,
      );
      _ruleData[diagnostic] = findMarginParameterLabel(node);
    }
  }

  SimpleIdentifier? findMarginParameterLabel(InstanceCreationExpression node) =>
      node.argumentList.arguments
          .whereType<NamedExpression>()
          .firstWhereOrNull((e) => e.name.label.name == 'margin')
          ?.name
          .label;
}

class UsePaddingFix extends ResolvedCorrectionProducer {
  UsePaddingFix({required super.context});

  @override
  FixKind? get fixKind => const FixKind(
    'leancode.lint.usePadding',
    DartFixKindPriority.standard,
    'Use Padding instead of Container',
  );

  @override
  CorrectionApplicability get applicability =>
      CorrectionApplicability.singleLocation;

  @override
  Future<void> compute(ChangeBuilder builder) async {
    if (diagnostic case final diagnostic?) {
      final margin = _ruleData[diagnostic]!;
      await builder.addDartFileEdit(file, (builder) {
        builder
          ..addSimpleReplacement(
            SourceRange(diagnostic.offset, diagnostic.length),
            'Padding',
          )
          ..addSimpleReplacement(range.node(margin), 'padding');
      });
    }
  }
}
