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
import 'package:collection/collection.dart';

const _supportedGetters = {
  'size',
  'orientation',
  'devicePixelRatio',
  'textScaleFactor',
  'textScaler',
  'platformBrightness',
  'padding',
  'viewInsets',
  'systemGestureInsets',
  'viewPadding',
  'alwaysUse24HourFormat',
  'accessibleNavigation',
  'invertColors',
  'highContrast',
  'onOffSwitchLabels',
  'disableAnimations',
  'boldText',
  'navigationMode',
  'gestureSettings',
  'displayFeatures',
  'supportsShowingSystemContextMenu',
};

class UseDedicatedMediaQueryMethods extends AnalysisRule {
  UseDedicatedMediaQueryMethods()
    : super(
        name: 'use_dedicated_media_query_methods',
        description:
            'Avoid using {0} to access only one property of MediaQueryData. '
            'Using aspects of the `MediaQuery` avoids unnecessary rebuilds.',
      );

  @override
  LintCode get diagnosticCode => LintCode(
    name,
    description,
    correctionMessage: 'Use the dedicated `{1}` method instead.',
  );

  @override
  void registerNodeProcessors(
    RuleVisitorRegistry registry,
    RuleContext context,
  ) {
    registry.addMethodInvocation(this, _Visitor(this, context));
  }
}

class _Visitor extends SimpleAstVisitor<void> {
  _Visitor(this.rule, this.context);

  final AnalysisRule rule;
  final RuleContext context;

  @override
  void visitMethodInvocation(MethodInvocation node) {
    if (_isValidMediaQueryUsage(node)) {
      return;
    }

    final replacementSuggestion = _getReplacementSuggestion(node);
    final parent = node.parent;

    if (replacementSuggestion == null || parent == null) {
      return;
    }

    rule.reportAtNode(
      parent,
      arguments: [node.toSource(), replacementSuggestion],
      // FIXME: use expando instead of data when possible
      // data: replacementSuggestion,
    );
  }

  String? _getReplacementSuggestion(MethodInvocation node) {
    final methodReplacement = _getReplacementMethodName(node);
    if (methodReplacement == null) {
      return null;
    }

    final contextVariableName = _getContextVariableName(node);
    if (contextVariableName == null) {
      return null;
    }

    final usedMaybe = methodReplacement.startsWith('maybe');
    final usedGetter = _getUsedGetter(node);
    final shouldAddQuestionMark =
        usedMaybe && usedGetter != null && _isGrandParentPropertyAccess(node);

    return 'MediaQuery.$methodReplacement($contextVariableName)${shouldAddQuestionMark ? '?' : ''}';
  }

  bool _isGrandParentPropertyAccess(MethodInvocation node) =>
      node.parent?.parent is PropertyAccess;

  String? _getContextVariableName(MethodInvocation node) =>
      node.argumentList.arguments.firstOrNull?.toString();

  String? _getReplacementMethodName(MethodInvocation node) {
    final usedGetter = _getUsedGetter(node);

    if (usedGetter == null || !_supportedGetters.contains(usedGetter)) {
      return null;
    }

    return switch (node.methodName.name) {
      'of' => '${usedGetter}Of',
      'maybeOf' =>
        'maybe${usedGetter[0].toUpperCase()}${usedGetter.substring(1)}Of',
      _ => null,
    };
  }

  bool _isValidMediaQueryUsage(MethodInvocation node) => switch (node) {
    MethodInvocation(
      target: SimpleIdentifier(name: 'MediaQuery'),
      methodName: SimpleIdentifier(name: 'of' || 'maybeOf'),
    ) =>
      false,
    _ => true,
  };

  String? _getUsedGetter(MethodInvocation node) => switch (node.parent) {
    PropertyAccess(
      target: MethodInvocation(target: SimpleIdentifier(name: 'MediaQuery')),
      propertyName: SimpleIdentifier(name: final propertyName),
    ) =>
      propertyName,
    _ => null,
  };
}

class ReplaceMediaQueryOfWithDedicatedMethodFix
    extends ResolvedCorrectionProducer {
  ReplaceMediaQueryOfWithDedicatedMethodFix({required super.context});

  @override
  FixKind? get fixKind => const FixKind(
    'leancode.lint.replaceMediaQueryOfWithDedicatedMethod',
    DartFixKindPriority.standard,
    'Replace with the dedicated MediaQuery method',
  );

  @override
  CorrectionApplicability get applicability =>
      CorrectionApplicability.singleLocation;

  @override
  Future<void> compute(ChangeBuilder builder) async {
    if (diagnostic case Diagnostic(
      data: final String suggestedReplacement,
      :final offset,
      :final length,
    )) {
      await builder.addDartFileEdit(
        file,
        (builder) => builder.addSimpleReplacement(
          SourceRange(offset, length),
          suggestedReplacement,
        ),
      );
    }
  }
}
