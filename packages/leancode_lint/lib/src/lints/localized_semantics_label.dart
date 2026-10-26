import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/token.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/error/error.dart';
import 'package:leancode_lint/src/helpers.dart';

/// Reports a string literal with hardcoded text that is passed as text for
/// screen readers, for example `Icon(Icons.close, semanticLabel: 'Close')`.
/// A screen reader reads it out exactly as written, in a single language, so
/// it should come from the app's localizations instead.
///
/// The rule checks:
///
/// - `semanticsLabel` and `semanticLabel` arguments of any widget or function,
///   which covers `Text`, `Icon`, `Image` and design system widgets
/// - the text arguments of `Semantics`, `SemanticsProperties`,
///   `SemanticsHintOverrides` and `CustomSemanticsAction`, such as `label`,
///   `hint` and `value`
///
/// A literal is only reported when its own text contains a letter, so
/// `'${l10n.price}: $amount'` and `''` are not reported. Both branches of
/// `?:` and `??` are checked.
class LocalizedSemanticsLabel() extends AnalysisRule {
  this : super(name: code.lowerCaseName, description: code.problemMessage);

  static const code = LintCode(
    'localized_semantics_label',
    'Screen readers read this hardcoded text as is, in a single language.',
    correctionMessage: 'Try using a localized string instead.',
    severity: .WARNING,
  );

  @override
  LintCode get diagnosticCode => code;

  @override
  void registerNodeProcessors(
    RuleVisitorRegistry registry,
    RuleContext context,
  ) {
    registry.addArgumentList(this, _Visitor(this, context));
  }
}

const _labelParameters = {'semanticsLabel', 'semanticLabel'};

const _semanticsTypes = {
  'Semantics',
  'SemanticsProperties',
  'SemanticsHintOverrides',
  'CustomSemanticsAction',
};

const _semanticsTextParameters = {
  'label',
  'value',
  'increasedValue',
  'decreasedValue',
  'hint',
  'tooltip',
  'onTapHint',
  'onLongPressHint',
};

final _letter = RegExp(r'\p{L}', unicode: true);

class _Visitor(final AnalysisRule rule, final RuleContext context)
    extends SimpleAstVisitor<void> {
  @override
  void visitArgumentList(ArgumentList node) {
    final isSemantics = switch (node.parent) {
      final InstanceCreationExpression creation => _semanticsTypes.any(
        (type) => isExpressionExactlyType(creation, type, 'flutter'),
      ),
      _ => false,
    };

    for (final argument in node.arguments.whereType<NamedArgument>()) {
      final name = argument.name.lexeme;
      if (_labelParameters.contains(name) ||
          (isSemantics && _semanticsTextParameters.contains(name))) {
        _hardcodedStrings(argument.argumentExpression)
            .forEach(rule.reportAtNode);
      }
    }
  }
}

Iterable<StringLiteral> _hardcodedStrings(Expression expression) sync* {
  switch (expression) {
    case StringLiteral() when _containsText(expression):
      yield expression;
    case ParenthesizedExpression(:final expression):
      yield* _hardcodedStrings(expression);
    case ConditionalExpression(:final thenExpression, :final elseExpression):
      yield* _hardcodedStrings(thenExpression);
      yield* _hardcodedStrings(elseExpression);
    case BinaryExpression(
      operator: Token(type: .QUESTION_QUESTION),
      :final leftOperand,
      :final rightOperand,
    ):
      yield* _hardcodedStrings(leftOperand);
      yield* _hardcodedStrings(rightOperand);
  }
}

bool _containsText(StringLiteral literal) => switch (literal) {
  SimpleStringLiteral(:final value) => _letter.hasMatch(value),
  AdjacentStrings(:final strings) => strings.any(_containsText),
  StringInterpolation(:final elements) =>
    elements.whereType<InterpolationString>().any(
      (element) => _letter.hasMatch(element.value),
    ),
};
