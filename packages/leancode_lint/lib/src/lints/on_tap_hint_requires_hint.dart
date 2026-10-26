import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/error/error.dart';
import 'package:leancode_lint/src/helpers.dart';

/// Reports `onTapHint` and `onLongPressHint` passed to `Semantics`, and
/// `hintOverrides` passed to `SemanticsProperties`, without a `hint`.
///
/// Hint overrides only change the hint Android reads for an action ("double
/// tap to ..."). iOS always ignores them, so without a `hint` VoiceOver users
/// get no hint at all.
class OnTapHintRequiresHint() extends AnalysisRule {
  this : super(name: code.lowerCaseName, description: code.problemMessage);

  static const code = LintCode(
    'on_tap_hint_requires_hint',
    "'{0}' is ignored on iOS, so VoiceOver users don't hear this hint.",
    correctionMessage: "Try also setting 'hint'.",
    severity: .WARNING,
  );

  @override
  LintCode get diagnosticCode => code;

  @override
  void registerNodeProcessors(
    RuleVisitorRegistry registry,
    RuleContext context,
  ) {
    registry.addInstanceCreationExpression(this, _Visitor(this, context));
  }
}

class _Visitor(final AnalysisRule rule, final RuleContext context)
    extends SimpleAstVisitor<void> {
  @override
  void visitInstanceCreationExpression(InstanceCreationExpression node) {
    final hintOverrides = switch (node) {
      _ when isExpressionExactlyType(node, 'Semantics', 'flutter') => const [
        'onTapHint',
        'onLongPressHint',
      ],
      _ when isExpressionExactlyType(node, 'SemanticsProperties', 'flutter') =>
        const ['hintOverrides'],
      _ => const <String>[],
    };
    if (hintOverrides.isEmpty ||
        namedArgumentValue(node.argumentList, 'hint') != null) {
      return;
    }

    for (final argument
        in node.argumentList.arguments.whereType<NamedArgument>()) {
      final name = argument.name.lexeme;
      if (hintOverrides.contains(name) &&
          argument.argumentExpression is! NullLiteral) {
        rule.reportAtToken(argument.name, arguments: [name]);
      }
    }
  }
}
