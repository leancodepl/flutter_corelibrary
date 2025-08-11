import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/error/error.dart' as error;
import 'package:analyzer/error/listener.dart';
import 'package:collection/collection.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

class UseDedicatedMediaQueryMethods extends DartLintRule {
  const UseDedicatedMediaQueryMethods()
    : super(
        code: const LintCode(
          name: 'use_dedicated_media_query_methods',
          errorSeverity: error.ErrorSeverity.WARNING,
          problemMessage:
              'Avoid using {0} to access only one property of MediaQueryData. '
              'Using aspects of the `MediaQuery` avoids unnecessary rebuilds.\n',
          correctionMessage: 'Use the dedicated `{1}` method instead.',
        ),
      );

  static const _supportedGetters = {
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

  @override
  List<Fix> getFixes() => [_ReplaceMediaQueryOfWithDedicatedMethodFix()];

  @override
  void run(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
  ) {
    context.registry.addMethodInvocation((node) {
      if (_isValidMediaQueryUsage(node)) {
        return;
      }

      final replacementSuggestion = _getReplacementSuggestion(node);
      final parent = node.parent;

      if (replacementSuggestion == null || parent == null) {
        return;
      }

      reporter.atNode(
        parent,
        code,
        arguments: [node.toSource(), replacementSuggestion],
        data: replacementSuggestion,
      );
    });
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

    return 'MediaQuery.$methodReplacement($contextVariableName)${usedMaybe && usedGetter != null && _isGrandParentPropertyAccess(node) ? '?' : ''}';
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

    final usedMethodName = _getUsedMethodName(node);

    return switch (usedMethodName) {
      'of' => '${usedGetter}Of',
      'maybeOf' when usedGetter.length > 1 =>
        'maybe${usedGetter[0].toUpperCase()}${usedGetter.substring(1)}Of',
      'maybeOf' => 'maybe${usedGetter.toUpperCase()}Of',
      _ => null,
    };
  }

  bool _isValidMediaQueryUsage(MethodInvocation node) {
    if (node.beginToken.lexeme != 'MediaQuery') {
      return true;
    }

    final methodName = _getUsedMethodName(node);

    return methodName != 'of' && methodName != 'maybeOf';
  }

  String? _getUsedGetter(MethodInvocation node) {
    if (node.parent case PropertyAccess(:final propertyName)) {
      return propertyName.name;
    }
    return null;
  }

  String _getUsedMethodName(MethodInvocation node) => node.methodName.name;
}

class _ReplaceMediaQueryOfWithDedicatedMethodFix extends DartFix {
  @override
  void run(
    CustomLintResolver resolver,
    ChangeReporter reporter,
    CustomLintContext context,
    error.AnalysisError analysisError,
    List<error.AnalysisError> others,
  ) {
    if (analysisError.data case final String suggestedReplacement) {
      reporter
          .createChangeBuilder(
            message: 'Replace with `$suggestedReplacement`',
            priority: 100,
          )
          .addDartFileEdit(
            (builder) => builder.addSimpleReplacement(
              analysisError.sourceRange,
              suggestedReplacement,
            ),
          );
    }
  }
}
