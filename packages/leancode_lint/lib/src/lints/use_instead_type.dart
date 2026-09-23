import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/token.dart';
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
      ..addDotShorthandPropertyAccess(this, visitor);
  }
}

class _Visitor(final UseInsteadType rule, final RuleContext context)
    extends GeneralizingAstVisitor<void> {
  final TypeChecker checker = rule.getChecker(context);

  @override
  void visitIdentifier(Identifier node) {
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

  /// `.new(...)` and `.named(...)` do not contain the constructed type's name.
  /// The type is the constructor's enclosing element.
  @override
  void visitDotShorthandConstructorInvocation(
    DotShorthandConstructorInvocation node,
  ) {
    _reportConstructor(node.element, node.period, node.constructorName);
  }

  /// A shorthand constructor tear-off, such as `text == .new`.
  @override
  void visitDotShorthandPropertyAccess(DotShorthandPropertyAccess node) {
    _reportConstructor(
      node.propertyName.element,
      node.period,
      node.propertyName,
    );
  }

  void _reportConstructor(
    Element? element,
    Token period,
    SimpleIdentifier name,
  ) {
    if (element is! ConstructorElement || _isInHide(name)) {
      return;
    }

    _reportIfMatches(
      element.enclosingElement,
      offset: period.offset,
      length: name.end - period.offset,
    );
  }

  void _handleElement(Element element, AstNode node) {
    if (_isInHide(node)) {
      return;
    }
    _reportIfMatches(element, offset: node.offset, length: node.length);
  }

  void _reportIfMatches(
    Element element, {
    required int offset,
    required int length,
  }) {
    try {
      if (checker.isExactly(element)) {
        rule.reportAtOffset(
          offset,
          length,
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
