import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/token.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/error/error.dart';
import 'package:leancode_lint/src/helpers.dart';
import 'package:leancode_lint/src/utils.dart';

/// Reports an `Icon` without a `semanticLabel` that is the only content of a
/// tappable widget without a label, for example
/// `IconButton(icon: Icon(Icons.close), onPressed: close)`. A screen reader
/// announces such a widget only as "button", or not at all.
///
/// The icon is reported when it is:
///
/// - the `icon` or `selectedIcon` of an `IconButton` without a `tooltip`
/// - the `child` of a `FloatingActionButton` without a `tooltip`
/// - the `child` of an `InkWell`, `InkResponse` or `GestureDetector` that
///   doesn't set `excludeFromSemantics: true`
///
/// It isn't reported when the tappable widget is wrapped, within the same
/// widget expression, in a `Tooltip` or in a `Semantics` with a `label`.
class IconOnlyButtonRequiresLabel() extends AnalysisRule {
  this : super(name: code.lowerCaseName, description: code.problemMessage);

  static const code = LintCode(
    'icon_only_button_requires_label',
    "This icon is the only content of a '{0}', so screen readers have no "
        'label to announce for it.',
    correctionMessage:
        "Try setting the icon's 'semanticLabel', or a 'tooltip' if the widget "
        'has one.',
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

typedef _TapTarget = ({Set<String> iconSlots, String? labelParameter});

const _tapTargets = <String, _TapTarget>{
  'IconButton': (
    iconSlots: {'icon', 'selectedIcon'},
    labelParameter: 'tooltip',
  ),
  'FloatingActionButton': (iconSlots: {'child'}, labelParameter: 'tooltip'),
  'InkWell': (iconSlots: {'child'}, labelParameter: null),
  'InkResponse': (iconSlots: {'child'}, labelParameter: null),
  'GestureDetector': (iconSlots: {'child'}, labelParameter: null),
};

class _Visitor(final AnalysisRule rule, final RuleContext context)
    extends SimpleAstVisitor<void> {
  @override
  void visitInstanceCreationExpression(InstanceCreationExpression node) {
    if (!isExpressionExactlyType(node, 'Icon', 'flutter') ||
        namedArgumentValue(node.argumentList, 'semanticLabel') != null) {
      return;
    }

    if (node.parent case NamedArgument(
      name: Token(lexeme: final slot),
      parent: ArgumentList(parent: final InstanceCreationExpression target),
    )) {
      final match = _tapTargets.entries.firstWhereOrNull(
        (entry) =>
            entry.value.iconSlots.contains(slot) &&
            isExpressionExactlyType(target, entry.key, 'flutter'),
      );
      if (match case MapEntry(key: final name, value: final tapTarget)
          when !_isLabelledOrExcluded(target, tapTarget) &&
              !_isLabelledByAncestor(target)) {
        rule.reportAtNode(node.constructorName, arguments: [name]);
      }
    }
  }
}

bool _isLabelledOrExcluded(
  InstanceCreationExpression target,
  _TapTarget tapTarget,
) {
  final arguments = target.argumentList;
  if (tapTarget.labelParameter case final labelParameter?
      when namedArgumentValue(arguments, labelParameter) != null) {
    return true;
  }
  return switch (namedArgumentValue(arguments, 'excludeFromSemantics')) {
    BooleanLiteral(value: true) => true,
    _ => false,
  };
}

/// Whether [widget] is wrapped in a `Tooltip` or a labelled `Semantics`,
/// looking up through the widget expression it's part of.
bool _isLabelledByAncestor(InstanceCreationExpression widget) {
  for (AstNode? node = widget.parent; node != null; node = node.parent) {
    switch (node) {
      case InstanceCreationExpression()
          when isExpressionExactlyType(node, 'Tooltip', 'flutter'):
        return true;
      case InstanceCreationExpression()
          when isExpressionExactlyType(node, 'Semantics', 'flutter'):
        if (namedArgumentValue(node.argumentList, 'label') != null) {
          return true;
        }
      case InstanceCreationExpression() ||
          NamedArgument() ||
          ArgumentList() ||
          ParenthesizedExpression() ||
          ConditionalExpression() ||
          ListLiteral():
        continue;
      default:
        return false;
    }
  }
  return false;
}
