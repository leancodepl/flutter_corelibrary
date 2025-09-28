import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/error/error.dart';
import 'package:leancode_lint/type_checker.dart';

abstract base class UseInsteadType extends AnalysisRule {
  UseInsteadType({
    required super.name,
    required super.description,
    required this.correctionMessage,
  });

  final String correctionMessage;

  @override
  LintCode get diagnosticCode =>
      LintCode(name, description, correctionMessage: correctionMessage);

  List<(String, TypeChecker)> getCheckers(RuleContext context);

  @override
  void registerNodeProcessors(
    RuleVisitorRegistry registry,
    RuleContext context,
  ) {
    final visitor = _Visitor(this, context);
    registry
      ..addPrefixedIdentifier(this, visitor)
      ..addSimpleIdentifier(this, visitor)
      ..addLibraryIdentifier(this, visitor)
      ..addNamedType(this, visitor);
  }
}

class _Visitor extends GeneralizingAstVisitor<void> {
  _Visitor(this.rule, this.context) : checkers = rule.getCheckers(context);

  final UseInsteadType rule;
  final RuleContext context;
  final List<(String, TypeChecker)> checkers;

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

  void _handleElement(Element element, AstNode node) {
    if (_isInHide(node)) {
      return;
    }

    for (final (preferredItemName, checker) in checkers) {
      try {
        if (checker.isExactly(element)) {
          // TODO: use item-specific lint codes
          rule.reportAtNode(
            node,
            arguments: [element.displayName, preferredItemName],
          );
        }
      } catch (err) {
        // isExactly crashes sometimes
      }
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
