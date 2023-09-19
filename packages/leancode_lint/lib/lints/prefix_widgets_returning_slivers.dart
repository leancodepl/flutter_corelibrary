import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/error/error.dart';
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';
import 'package:leancode_lint/helpers.dart';

final class PrefixWidgetsReturningSliversConfig {
  const PrefixWidgetsReturningSliversConfig(this.applicationPrefix);

  factory PrefixWidgetsReturningSliversConfig.fromConfig(
    Map<String, Object?> json,
  ) {
    return PrefixWidgetsReturningSliversConfig(
      json['application_prefix'] as String?,
    );
  }

  final String? applicationPrefix;
}

/// Displays warning for widgets which return slivers but do not have the
/// `Sliver`/`_Sliver` (or `${AppPrefix}Sliver`/`_${AppPrefix}Sliver` if
/// `AppPrefix` is specified in the config) prefix in their name.
class PrefixWidgetsReturningSlivers extends DartLintRule {
  PrefixWidgetsReturningSlivers({required this.config})
      : super(code: _getLintCode(config));

  PrefixWidgetsReturningSlivers.fromConfigs(CustomLintConfigs configs)
      : this(
          config: PrefixWidgetsReturningSliversConfig.fromConfig(
            configs.rules[ruleName]?.json ?? {},
          ),
        );

  final PrefixWidgetsReturningSliversConfig config;

  static const ruleName = 'prefix_widgets_returning_slivers';

  @override
  void run(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
  ) {
    context.registry.addClassDeclaration(
      (node) {
        final isThisWidgetClass = isWidgetClass(node);
        if (!isThisWidgetClass) {
          return;
        }

        final startsWithSliver = _hasSliverPrefix(node.name.lexeme);
        if (startsWithSliver) {
          return;
        }

        final buildMethod = getBuildMethod(node);
        if (buildMethod == null) {
          return;
        }

        // Get all return expressions from build method
        final returnExpressions = getAllReturnExpressions(buildMethod.body);

        final isSliver = _anyIsSliver(returnExpressions.nonNulls);

        if (isSliver) {
          reporter.reportErrorForToken(
            _getLintCode(config, node.name.lexeme),
            node.name,
          );
        }
      },
    );
  }

  late final possiblePrefixes = [
    'Sliver',
    '_Sliver',
    if (config.applicationPrefix case final applicationPrefix?) ...[
      '${applicationPrefix}Sliver',
      '_${applicationPrefix}Sliver',
    ],
  ];

  bool _hasSliverPrefix(String className) =>
      possiblePrefixes.any(className.startsWith);

  bool _anyIsSliver(Iterable<Expression> expressions) => expressions.any(
        (expression) =>
            expression is InstanceCreationExpression &&
            _hasSliverPrefix(expression.constructorName.type.name2.lexeme),
      );

  static LintCode _getLintCode(
    PrefixWidgetsReturningSliversConfig config, [
    String? className,
  ]) {
    const problemMessageBase =
        'Prefix widget names of widgets which return slivers in the build method.';

    final suggestedName = () {
      var name = className;
      if (name == null) {
        return null;
      }
      final suggested = StringBuffer();
      if (name.startsWith('_')) {
        suggested.write('_');
        name = name.substring(1);
      }
      if (config.applicationPrefix case final applicationPrefix?
          when name.startsWith(applicationPrefix)) {
        suggested.write(applicationPrefix);
        name = name.substring(applicationPrefix.length);
      }
      suggested
        ..write('Sliver')
        ..write(name);

      return suggested.toString();
    }();

    return LintCode(
      name: ruleName,
      problemMessage: problemMessageBase,
      correctionMessage:
          suggestedName != null ? 'Consider renaming to $suggestedName' : null,
      errorSeverity: ErrorSeverity.WARNING,
    );
  }
}
