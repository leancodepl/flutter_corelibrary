import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/token.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/error/error.dart';
import 'package:analyzer/source/source_range.dart';
import 'package:analyzer_plugin/utilities/range_factory.dart';
import 'package:leancode_lint/config.dart';

/// Flags a function, method, constructor or closure whose cognitive complexity
/// is over `LeanCodeLintConfig.cognitiveComplexity.maximum`.
///
/// Scored like SonarSource's Cognitive Complexity: each break in the linear
/// flow costs one, plus one per level it is nested at. As in SonarJS, a
/// closure or local function is scored on its own, and only the first level of
/// nested functions adds a level, so `test` closures inside `group` inside
/// `main` are not penalized for the test framework's structure. `??`, `?.` and
/// an early `return` cost nothing.
class CognitiveComplexity({required final CognitiveComplexityConfig config})
    extends AnalysisRule {
  this : super(name: code.lowerCaseName, description: code.problemMessage);

  static const code = LintCode(
    'cognitive_complexity',
    '{0} has a cognitive complexity of {1}, over the maximum of {2}.',
    correctionMessage:
        'Try extracting part of it into a function, or returning early to '
        'reduce nesting.',
    severity: .WARNING,
  );

  @override
  LintCode get diagnosticCode => code;

  @override
  void registerNodeProcessors(
    RuleVisitorRegistry registry,
    RuleContext context,
  ) {
    final visitor = _Visitor(this, config.maximum);
    registry
      ..addFunctionDeclaration(this, visitor)
      ..addMethodDeclaration(this, visitor)
      ..addConstructorDeclaration(this, visitor);
  }
}

// Only declarations outside any other function are visited here; the
// functions nested in them are scored as the scorer reaches them.
class _Visitor(final AnalysisRule rule, final int maximum)
    extends SimpleAstVisitor<void> {
  @override
  void visitFunctionDeclaration(FunctionDeclaration node) {
    if (node.parent is CompilationUnit) {
      _Scorer(rule, maximum).score(
        "'${node.name.lexeme}'",
        range.token(node.name),
        [node.functionExpression.body],
      );
    }
  }

  @override
  void visitMethodDeclaration(MethodDeclaration node) {
    _Scorer(
      rule,
      maximum,
    ).score("'${node.name.lexeme}'", range.token(node.name), [node.body]);
  }

  @override
  void visitConstructorDeclaration(ConstructorDeclaration node) {
    _Scorer(rule, maximum).score(
      "'${[?node.typeName?.name, ?node.name?.lexeme].join('.')}'",
      node.errorRange,
      [...node.initializers, node.body],
    );
  }
}

class _Scorer(final AnalysisRule rule, final int maximum)
    extends RecursiveAstVisitor<void> {
  var _complexity = 0;
  var _nesting = 0;
  var _functionDepth = 0;

  void score(String name, SourceRange at, List<AstNode> parts) {
    final enclosing = _complexity;
    _complexity = 0;
    _functionDepth++;
    for (final part in parts) {
      part.accept(this);
    }
    if (_complexity > maximum) {
      rule.reportAtSourceRange(at, arguments: [name, _complexity, maximum]);
    }
    _complexity = enclosing;
    _functionDepth--;
  }

  void _structural() => _complexity += 1 + _nesting;

  void _nested(AstNode? node) {
    _nesting++;
    node?.accept(this);
    _nesting--;
  }

  @override
  void visitFunctionExpression(FunctionExpression node) {
    final nests = _functionDepth == 1;
    if (nests) {
      _nesting++;
    }
    if (node.parent case final FunctionDeclaration declaration) {
      score("'${declaration.name.lexeme}'", range.token(declaration.name), [
        node.body,
      ]);
    } else {
      score('A closure', range.startEnd(node, node.parameters ?? node), [
        node.body,
      ]);
    }
    if (nests) {
      _nesting--;
    }
  }

  @override
  void visitIfStatement(IfStatement node) {
    _structural();
    _ifStatement(node);
  }

  // An `else if` costs one but no nesting: it reads as a sibling of the `if`.
  void _ifStatement(IfStatement node) {
    node.expression.accept(this);
    node.caseClause?.accept(this);
    _nested(node.thenStatement);
    switch (node.elseStatement) {
      case final IfStatement elseIf:
        _complexity++;
        _ifStatement(elseIf);
      case final elseStatement?:
        _complexity++;
        _nested(elseStatement);
      case null:
    }
  }

  @override
  void visitIfElement(IfElement node) {
    _structural();
    _ifElement(node);
  }

  void _ifElement(IfElement node) {
    node.expression.accept(this);
    node.caseClause?.accept(this);
    _nested(node.thenElement);
    switch (node.elseElement) {
      case final IfElement elseIf:
        _complexity++;
        _ifElement(elseIf);
      case final elseElement?:
        _complexity++;
        _nested(elseElement);
      case null:
    }
  }

  @override
  void visitConditionalExpression(ConditionalExpression node) {
    _structural();
    node.condition.accept(this);
    _nested(node.thenExpression);
    _nested(node.elseExpression);
  }

  @override
  void visitSwitchStatement(SwitchStatement node) {
    _structural();
    node.expression.accept(this);
    node.members.forEach(_nested);
  }

  @override
  void visitSwitchExpression(SwitchExpression node) {
    _structural();
    node.expression.accept(this);
    node.cases.forEach(_nested);
  }

  @override
  void visitForStatement(ForStatement node) {
    _structural();
    node.forLoopParts.accept(this);
    _nested(node.body);
  }

  @override
  void visitForElement(ForElement node) {
    _structural();
    node.forLoopParts.accept(this);
    _nested(node.body);
  }

  @override
  void visitWhileStatement(WhileStatement node) {
    _structural();
    node.condition.accept(this);
    _nested(node.body);
  }

  @override
  void visitDoStatement(DoStatement node) {
    _structural();
    _nested(node.body);
    node.condition.accept(this);
  }

  @override
  void visitCatchClause(CatchClause node) {
    _structural();
    _nested(node.body);
  }

  @override
  void visitBreakStatement(BreakStatement node) {
    if (node.label != null) {
      _complexity++;
    }
  }

  @override
  void visitContinueStatement(ContinueStatement node) {
    if (node.label != null) {
      _complexity++;
    }
  }

  // `a && b && c` costs one, `a && b || c` two: each run of one operator in
  // an unparenthesized chain is one step to follow.
  @override
  void visitBinaryExpression(BinaryExpression node) {
    if (_isLogical(node) && !_isLogical(node.parent)) {
      TokenType? previous;
      for (final operator in _logicalOperators(node)) {
        if (operator != previous) {
          _complexity++;
        }
        previous = operator;
      }
    }
    super.visitBinaryExpression(node);
  }
}

bool _isLogical(AstNode? node) =>
    node is BinaryExpression &&
    (node.operator.type == .AMPERSAND_AMPERSAND ||
        node.operator.type == .BAR_BAR);

Iterable<TokenType> _logicalOperators(Expression node) sync* {
  if (node case final BinaryExpression binary when _isLogical(binary)) {
    yield* _logicalOperators(binary.leftOperand);
    yield binary.operator.type;
    yield* _logicalOperators(binary.rightOperand);
  }
}
