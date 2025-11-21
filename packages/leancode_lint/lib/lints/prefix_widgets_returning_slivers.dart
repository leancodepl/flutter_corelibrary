import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/error/error.dart';
import 'package:leancode_lint/config.dart';
import 'package:leancode_lint/helpers.dart';

/// Displays warning for widgets which return slivers but do not have the
/// `Sliver`/`_Sliver` (or `${AppPrefix}Sliver`/`_${AppPrefix}Sliver` if
/// `AppPrefix` is specified in the config) prefix in their name.
class PrefixWidgetsReturningSlivers extends AnalysisRule {
  PrefixWidgetsReturningSlivers()
    : super(name: code.name, description: code.problemMessage);

  static const code = LintCode(
    'prefix_widgets_returning_slivers',
    'Prefix widget names of widgets which return slivers in the build method.',
    correctionMessage: 'Consider renaming to {0}.',
    severity: .WARNING,
  );

  @override
  LintCode get diagnosticCode => code;

  @override
  void registerNodeProcessors(
    RuleVisitorRegistry registry,
    RuleContext context,
  ) {
    final config = LeancodeLintConfig.fromRuleContext(context);

    registry.addClassDeclaration(this, _Visitor(this, context, config));
  }
}

class _Visitor extends SimpleAstVisitor<void> {
  _Visitor(this.rule, this.context, this.config);

  final AnalysisRule rule;
  final RuleContext context;
  final LeancodeLintConfig config;

  @override
  void visitClassDeclaration(ClassDeclaration node) {
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
      rule.reportAtToken(
        node.name,
        arguments: [_getSuggestedClassName(config, node.name.lexeme)],
      );
    }
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
        _hasSliverPrefix(expression.constructorName.type.name.lexeme),
  );

  static String _getSuggestedClassName(
    LeancodeLintConfig config,
    String className,
  ) {
    var name = className;

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
  }
}
