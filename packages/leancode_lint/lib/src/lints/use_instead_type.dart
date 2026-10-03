import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/error/error.dart';
import 'package:leancode_lint/src/type_checker.dart';

/// Enforces that items that have a replacement defined are used.
abstract base class UseInsteadType({
  required super.name,
  required super.description,
  required final String correctionMessage,
  final DiagnosticSeverity severity = .WARNING,
}) extends AnalysisRule {
  @override
  LintCode get diagnosticCode => .new(
    name,
    description,
    correctionMessage: correctionMessage,
    severity: severity,
  );

  String get preferredItem;

  TypeChecker getChecker(RuleContext context);

  @override
  void registerNodeProcessors(
    RuleVisitorRegistry registry,
    RuleContext context,
  ) {
    final visitor = _Visitor(this, context);
    registry
      ..addPrefixedIdentifier(this, visitor)
      ..addSimpleIdentifier(this, visitor)
      ..addNamedType(this, visitor)
      ..addDotShorthandConstructorInvocation(this, visitor)
      ..addDotShorthandInvocation(this, visitor)
      ..addDotShorthandPropertyAccess(this, visitor);
  }
}

class _Visitor(final UseInsteadType rule, final RuleContext context)
    extends SimpleAstVisitor<void> {
  final TypeChecker checker = rule.getChecker(context);

  @override
  void visitPrefixedIdentifier(PrefixedIdentifier node) {
    if (node.element case final element?) {
      _handleElement(element, node);
    }
  }

  @override
  void visitSimpleIdentifier(SimpleIdentifier node) {
    // `prefix.Type` is a PrefixedIdentifier that resolves to the same element
    // as its `Type` part. It is reported as a whole in visitPrefixedIdentifier,
    // so skip the inner identifier to avoid a duplicate report.
    if (node.parent
        case PrefixedIdentifier(
          prefix: SimpleIdentifier(element: PrefixElement()),
          :final identifier,
        )
        when identifier == node) {
      return;
    }
    if (node.element case final element?) {
      _handleElement(element, node);
    }
  }

  @override
  void visitNamedType(NamedType node) {
    if (node.element case final element?) {
      _handleElement(element, node);
    }
  }

  // Dot shorthands don't name the type explicitly, so check the type declaring
  // the referenced member instead.

  @override
  void visitDotShorthandConstructorInvocation(
    DotShorthandConstructorInvocation node,
  ) => _handleDotShorthandMember(node.constructorName);

  @override
  void visitDotShorthandInvocation(DotShorthandInvocation node) =>
      _handleDotShorthandMember(node.memberName);

  @override
  void visitDotShorthandPropertyAccess(DotShorthandPropertyAccess node) =>
      _handleDotShorthandMember(node.propertyName);

  void _handleDotShorthandMember(SimpleIdentifier memberName) {
    if (memberName.element?.enclosingElement case final enclosingElement?) {
      _handleElement(enclosingElement, memberName);
    }
  }

  void _handleElement(Element element, AstNode node) {
    if (_isInHide(node)) {
      return;
    }
    try {
      if (checker.isExactly(element)) {
        rule.reportAtNode(
          node,
          arguments: [element.displayName, rule.preferredItem],
        );
      }
    } catch (err) {
      // isExactly crashes sometimes
    }
  }

  bool _isInHide(AstNode node) {
    if (node.parent case final parent?) {
      if (parent is HideCombinator) {
        return true;
      }
      return _isInHide(parent);
    } else {
      return false;
    }
  }
}
