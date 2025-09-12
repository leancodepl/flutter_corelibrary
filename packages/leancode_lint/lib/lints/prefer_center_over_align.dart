import 'package:analysis_server_plugin/edit/dart/correction_producer.dart';
import 'package:analysis_server_plugin/edit/dart/dart_fix_kind_priority.dart';
import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/diagnostic/diagnostic.dart';
import 'package:analyzer/error/error.dart';
import 'package:analyzer/source/source_range.dart';
import 'package:analyzer_plugin/utilities/change_builder/change_builder_core.dart';
import 'package:analyzer_plugin/utilities/fixes/fixes.dart';
import 'package:analyzer_plugin/utilities/range_factory.dart';
import 'package:leancode_lint/helpers.dart';

class PreferCenterOverAlign extends AnalysisRule {
  PreferCenterOverAlign()
    : super(
        name: 'prefer_center_over_align',
        description:
            'Use the Center widget instead of the Align widget with the alignment parameter set to Alignment.center',
      );

  @override
  LintCode get diagnosticCode =>
      LintCode(name, description, correctionMessage: 'Replace with Center');

  @override
  void registerNodeProcessors(
    RuleVisitorRegistry registry,
    RuleContext context,
  ) {
    registry.addInstanceCreationExpression(this, _Visitor(this, context));
  }
}

class _Visitor extends SimpleAstVisitor<void> {
  _Visitor(this.rule, this.context);

  final AnalysisRule rule;
  final RuleContext context;

  @override
  void visitInstanceCreationExpression(InstanceCreationExpression node) {
    final data = _analyzeAlignInstanceCreationExpression(node);
    if (data case final data? when data.isAlignmentCenter) {
      // FIXME: use expando instead of data when possible
      rule.reportAtNode(node.constructorName /*data: data*/);
    }
  }

  _PreferCenterOverAlignData? _analyzeAlignInstanceCreationExpression(
    InstanceCreationExpression node,
  ) {
    if (!isExpressionExactlyType(node, 'Align', 'flutter')) {
      return null;
    }
    final arguments = node.argumentList.arguments;
    var hasAlignmentArgument = false;

    for (final argument in arguments.whereType<NamedExpression>()) {
      if (argument.name.label.name == 'alignment') {
        hasAlignmentArgument = true;
        if (_isValueAlignmentCenter(argument)) {
          return _PreferCenterOverAlignData(
            isAlignmentCenter: true,
            alignmentExpression: argument,
            listOfArguments: arguments,
          );
        }
      }
    }
    if (!hasAlignmentArgument) {
      return _PreferCenterOverAlignData(isAlignmentCenter: true);
    }
    return null;
  }

  // TODO: Refactor method below with: computeConstantValue() (https://github.com/dart-lang/sdk/blob/4c4a1d3815a754f7a14112fb0f96030869e305f9/pkg/analyzer/lib/src/dart/ast/ast.dart#L7663)
  // once leancode_lint is upgraded
  bool _isValueAlignmentCenter(NamedExpression argument) {
    return switch (argument.expression) {
      PrefixedIdentifier(name: 'Alignment.center') => true,
      InstanceCreationExpression(
        staticType: final type,
        argumentList: ArgumentList(:final arguments),
      )
          when type?.getDisplayString() == 'Alignment' &&
              arguments.length == 2 =>
        _isEveryValueZero(arguments),
      _ => false,
    };
  }

  bool _isEveryValueZero(List<Expression> arguments) => arguments.every(
    (argument) => switch (argument) {
      IntegerLiteral(value: 0) || DoubleLiteral(value: 0) => true,
      _ => false,
    },
  );
}

class _PreferCenterOverAlignData {
  _PreferCenterOverAlignData({
    required this.isAlignmentCenter,
    this.alignmentExpression,
    this.listOfArguments,
  });

  final bool isAlignmentCenter;
  final Expression? alignmentExpression;
  final NodeList<Expression>? listOfArguments;
}

class PreferCenterOverAlignFix extends ResolvedCorrectionProducer {
  PreferCenterOverAlignFix({required super.context});

  @override
  FixKind? get fixKind => const FixKind(
    'leancode.lint.preferCenterOverAlign',
    DartFixKindPriority.standard,
    'Replace with Center',
  );

  // FIXME: revise applicability of all fixes
  @override
  CorrectionApplicability get applicability =>
      CorrectionApplicability.singleLocation;

  @override
  Future<void> compute(ChangeBuilder builder) async {
    await builder.addDartFileEdit(file, (builder) {
      if (diagnostic case Diagnostic(
        :final offset,
        :final length,
        :final data,
      )) {
        builder.addSimpleReplacement(SourceRange(offset, length), 'Center');
        if (data case _PreferCenterOverAlignData(
          :final listOfArguments?,
          :final alignmentExpression?,
        )) {
          builder.addDeletion(
            range.nodeInList(listOfArguments, alignmentExpression),
          );
        }
      }
    });
  }
}
