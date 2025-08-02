import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/error/error.dart' as error;
import 'package:analyzer/error/listener.dart';
import 'package:collection/collection.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

class AvoidUsingMediaQueryOfLint extends DartLintRule {
  const AvoidUsingMediaQueryOfLint()
    : super(
        code: const LintCode(
          name: 'avoid_using_media_query_of',
          errorSeverity: error.ErrorSeverity.WARNING,
          problemMessage: 'Avoid using `MediaQuery.of(context)`',
          correctionMessage: 'Use dedicated `{0}` method instead',
        ),
      );

  static const _supportedGetters = [
    'accessibleNavigation',
    'alwaysUse24HourFormat',
    'boldText',
    'devicePixelRatio',
    'disableAnimations',
    'displayFeatures',
    'gestureSettings',
    'highContrast',
    'invertColors',
    'navigationMode',
    'onOffSwitchLabels',
    'orientation',
    'padding',
    'platformBrightness',
    'size',
    'textScaler',
    'viewInsets',
    'viewPadding',
  ];

  @override
  List<Fix> getFixes() => [_ReplaceMediaQueryOfWithDedicatedMethodFix()];

  @override
  void run(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
  ) {
    context.registry.addMethodInvocation((node) {
      if (_isValidMediaQueryUsageOrNA(node)) {
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
        arguments: [replacementSuggestion],
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
    final usedGetter = _usedGetter(node);

    return 'MediaQuery.$methodReplacement($contextVariableName)${usedMaybe && usedGetter != null ? '?' : ''}';
  }

  String? _getContextVariableName(MethodInvocation node) {
    return node.argumentList.arguments.firstOrNull?.toString();
  }

  String? _getReplacementMethodName(MethodInvocation node) {
    final usedGetter = _usedGetter(node);

    if (usedGetter == null ||
        _supportedGetters.none((getter) => getter == usedGetter)) {
      return null;
    }

    final usedMethodName = _usedMethodName(node);

    return switch (usedMethodName) {
      'of' => '${usedGetter}Of',
      'maybeOf' when usedGetter.length > 1 =>
        'maybe${usedGetter[0].toUpperCase()}${usedGetter.substring(1).toLowerCase()}Of',
      'maybeOf' => 'maybe${usedGetter.toUpperCase()}Of',
      _ => null,
    };
  }

  bool _isValidMediaQueryUsageOrNA(MethodInvocation node) {
    if (node.beginToken.lexeme != 'MediaQuery') {
      return true;
    }

    final methodName = _usedMethodName(node);

    return methodName != 'of' && methodName != 'maybeOf';
  }

  String? _usedGetter(MethodInvocation node) =>
      node.parent?.toSource().split('.').lastOrNull;

  String _usedMethodName(MethodInvocation node) =>
      node.function.beginToken.lexeme;
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
