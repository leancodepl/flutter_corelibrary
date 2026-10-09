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
/// is over `LeanCodeLintConfig.cognitiveComplexity.maximum` (15 by default).
///
/// Cognitive Complexity is SonarSource's measure of how hard code is to follow
/// (https://www.sonarsource.com/docs/CognitiveComplexity.pdf). Unlike
/// cyclomatic complexity, which counts paths, it charges for nesting, so three
/// nested loops cost more than three loops one after another.
///
/// Scoring:
///
/// | Construct                                          | Cost              |
/// | -------------------------------------------------- | ----------------- |
/// | `if`, `switch` (statement or expression), `?:`     | 1 + nesting level |
/// | `for`, `while`, `do`, collection `for`, `catch`    | 1 + nesting level |
/// | `else if`, `else`                                  | 1                 |
/// | `break` or `continue` to a label                   | 1                 |
/// | each run of one operator in an `&&`/`              |                   |
/// | collection `if`, `case` patterns, `when` guards    | 0                 |
/// | `?.`, `?..`, `?[]`, `??`, `??=`, `!`, `...?`, `?x` | 0                 |
/// | early `return`, `try`, `finally`                   | 0                 |
///
/// The bodies of the constructs costing "1 + nesting level", and the branches
/// of `else`, nest one level deeper. A condition is scored at the level of its
/// construct. `a && b && c` costs 1, `a && b || c` costs 2, and parentheses
/// start a new chain.
///
/// Each function is reported on its own, at its name, a constructor's name, or
/// a closure's parameters. Deviations from SonarSource's paper, and why:
///
/// - A closure or local function is scored on its own, and only the first
///   level of nested functions adds a nesting level, as in SonarJS. Dart tests
///   sit in `main`, so with every level counted, a `test` in a `group` would
///   start two levels deep before its first `if`.
/// - A collection `if` costs nothing: a conditional child in a widget list
///   reads like JSX's `cond && <X/>`, which SonarJS ignores too. A collection
///   `for` still costs like a loop.
/// - `||` costs like `&&`. SonarJS ignores `||` because in JavaScript it also
///   supplies defaults (`name || 'Anon'`); in Dart it only takes `bool`, and
///   defaults use `??`, which is free.
class CognitiveComplexity({required final CognitiveComplexityConfig config})
    extends AnalysisRule {
  this : super(name: code.lowerCaseName, description: code.problemMessage);

  static const code = LintCode(
    'cognitive_complexity',
    'This {0} has a cognitive complexity of {1}, over the maximum of {2}.',
    correctionMessage:
        'Extract part of it into a function, or return early to reduce '
        'nesting.',
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
      _Scorer(rule, maximum).score('function', range.token(node.name), [
        node.functionExpression.body,
      ]);
    }
  }

  @override
  void visitMethodDeclaration(MethodDeclaration node) {
    _Scorer(rule, maximum).score('method', range.token(node.name), [node.body]);
  }

  @override
  void visitConstructorDeclaration(ConstructorDeclaration node) {
    _Scorer(
      rule,
      maximum,
    ).score('constructor', node.errorRange, [...node.initializers, node.body]);
  }
}

class _Scorer(final AnalysisRule rule, final int maximum)
    extends RecursiveAstVisitor<void> {
  var _complexity = 0;
  var _nesting = 0;
  var _functionDepth = 0;

  void score(String kind, SourceRange at, List<AstNode> parts) {
    final enclosing = _complexity;
    _complexity = 0;
    _functionDepth++;
    for (final part in parts) {
      part.accept(this);
    }
    if (_complexity > maximum) {
      rule.reportAtSourceRange(at, arguments: [kind, _complexity, maximum]);
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
      score('function', range.token(declaration.name), [node.body]);
    } else {
      score('closure', range.startEnd(node, node.parameters ?? node), [
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
