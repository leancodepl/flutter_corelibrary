import 'package:analysis_server_plugin/registry.dart';
import 'package:analysis_server_plugin/src/correction/fix_generators.dart';
import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/token.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/error/error.dart';
import 'package:analyzer/source/source_range.dart';
import 'package:leancode_lint/type_checker.dart';
import 'package:leancode_lint/utils.dart';

String typeParametersString(
  Iterable<TypeParameter> typeParameters, {
  bool withBounds = false,
}) {
  final parameters = typeParameters
      .map((e) => withBounds ? e.toSource() : e.name)
      .join(', ');

  if (parameters.isNotEmpty) {
    return '<$parameters>';
  } else {
    return '';
  }
}

Expression? maybeGetSingleReturnExpression(FunctionBody body) {
  return switch (body) {
    ExpressionFunctionBody(:final expression) ||
    BlockFunctionBody(
      block: Block(statements: [ReturnStatement(:final expression?)]),
    ) => expression,
    _ => null,
  };
}

class _HookExpressionsGatherer extends GeneralizingAstVisitor<void> {
  final List<InvocationExpression> _hookExpressions = [];

  static List<InvocationExpression> gather(AstNode node) {
    final visitor = _HookExpressionsGatherer();
    node.accept(visitor);
    return visitor._hookExpressions;
  }

  // use + upper case letter to avoid cases like "user"
  static final _isHookRegex = RegExp('^_?use[0-9A-Z]');

  @override
  void visitInstanceCreationExpression(InstanceCreationExpression node) {
    switch (maybeHookBuilderBody(node)) {
      case null:
        // It is not a hook builder, let's continue searching
        return super.visitInstanceCreationExpression(node);
      case final _:
        // this is a hook builder, so it has a new hook context for used hooks: stop recursing
        return;
    }
  }

  @override
  void visitInvocationExpression(InvocationExpression node) {
    if (_isHookRegex.hasMatch(node.beginToken.lexeme)) {
      _hookExpressions.add(node);
    }

    super.visitInvocationExpression(node);
  }
}

List<InvocationExpression> getAllInnerHookExpressions(AstNode node) {
  return _HookExpressionsGatherer.gather(node);
}

/// Given an instance creation, returns the builder function body if the node is a HookBuilder.
FunctionBody? maybeHookBuilderBody(InstanceCreationExpression node) {
  final classElement = node.constructorName.type.element2;
  if (classElement == null) {
    return null;
  }

  final isHookBuilder = const TypeChecker.any([
    TypeChecker.fromName('HookBuilder', packageName: 'flutter_hooks'),
    TypeChecker.fromName('HookConsumer', packageName: 'hooks_riverpod'),
  ]).isExactly(classElement);
  if (!isHookBuilder) {
    return null;
  }

  final builderParameter = node.argumentList.arguments
      .whereType<NamedExpression>()
      .firstWhereOrNull((e) => e.name.label.name == 'builder');
  if (builderParameter case NamedExpression(
    expression: FunctionExpression(:final body),
  )) {
    return body;
  }

  return null;
}

class _ReturnExpressionGatherer extends GeneralizingAstVisitor<void> {
  final List<Expression?> _returnExpressions = [];

  static List<Expression?> gather(AstNode node) {
    final visitor = _ReturnExpressionGatherer();
    node.visitChildren(visitor);
    return visitor._returnExpressions;
  }

  @override
  void visitFunctionBody(FunctionBody node) {
    // stop recursing on a new function body, return statements will be from a different scope
  }

  @override
  void visitReturnStatement(ReturnStatement node) {
    _returnExpressions.add(node.expression);
  }
}

/// Returns all return expressions of a function body.
List<Expression?> getAllReturnExpressions(FunctionBody body) {
  return switch (body) {
    BlockFunctionBody(:final block) => _ReturnExpressionGatherer.gather(block),
    ExpressionFunctionBody(:final expression) => [expression],
    EmptyFunctionBody() || NativeFunctionBody() => const [],
  };
}

bool isWidgetClass(ClassDeclaration node) => switch (node.declaredFragment) {
  final fragment? => const TypeChecker.any([
    TypeChecker.fromName('StatelessWidget', packageName: 'flutter'),
    TypeChecker.fromName('State', packageName: 'flutter'),
    TypeChecker.fromName('HookWidget', packageName: 'flutter_hooks'),
  ]).isSuperOf(fragment.element),
  _ => false,
};

MethodDeclaration? getBuildMethod(ClassDeclaration node) => node.members
    .whereType<MethodDeclaration>()
    .firstWhereOrNull((member) => member.name.lexeme == 'build');

extension ExpressionExtensions on Expression {
  SourceRange get sourceRange => SourceRange(offset, length);
}

extension NodeLintRegistryExtensions on RuleVisitorRegistry {
  void addRegularComment(
    AnalysisRule rule,
    void Function(Token comment) listener,
  ) {
    addCompilationUnit(rule, _RegularCommentVisitor(listener));
  }

  void addHookWidgetBody(
    AnalysisRule rule,
    void Function(FunctionBody node, AstNode diagnosticNode) listener, {
    bool isExactly = false,
  }) {
    final visitor = _HookWidgetBodyVisitor(listener, isExactly);
    addInstanceCreationExpression(rule, visitor);
    addClassDeclaration(rule, visitor);
  }
}

class _RegularCommentVisitor extends SimpleAstVisitor<void> {
  _RegularCommentVisitor(this.listener);

  final void Function(Token comment) listener;

  @override
  void visitCompilationUnit(CompilationUnit node) {
    bool isRegularComment(Token commentToken) {
      final token = commentToken.toString();

      return !token.startsWith('///') && token.startsWith('//');
    }

    Token? token = node.root.beginToken;
    while (token != null) {
      Token? commentToken = token.precedingComments;
      while (commentToken != null) {
        if (isRegularComment(commentToken)) {
          listener(commentToken);
        }
        commentToken = commentToken.next;
      }

      if (token == token.next) {
        break;
      }

      token = token.next;
    }
  }
}

class _HookWidgetBodyVisitor extends SimpleAstVisitor<void> {
  _HookWidgetBodyVisitor(this.listener, this.isExactly);

  final void Function(FunctionBody node, AstNode diagnosticNode) listener;
  final bool isExactly;

  @override
  void visitInstanceCreationExpression(InstanceCreationExpression node) {
    if (maybeHookBuilderBody(node) case final body?) {
      listener(body, node.constructorName);
    }
  }

  @override
  void visitClassDeclaration(ClassDeclaration node) {
    final element = node.declaredFragment?.element;
    if (element == null) {
      return;
    }

    const checker = TypeChecker.any([
      TypeChecker.fromName('HookWidget', packageName: 'flutter_hooks'),
      TypeChecker.fromName('HookConsumerWidget', packageName: 'hooks_riverpod'),
    ]);

    final AstNode diagnosticNode;
    if (isExactly) {
      final superclass = node.extendsClause?.superclass;
      final superclassElement = superclass?.element2;
      if (superclass == null || superclassElement == null) {
        return;
      }

      final isDirectHookWidget = checker.isExactly(superclassElement);
      if (!isDirectHookWidget) {
        return;
      }
      diagnosticNode = superclass;
    } else {
      final isHookWidget = checker.isSuperOf(element);
      if (!isHookWidget) {
        return;
      }
      diagnosticNode = node;
    }

    final buildMethod = getBuildMethod(node);
    if (buildMethod == null) {
      return;
    }

    listener(buildMethod.body, diagnosticNode);
  }
}

mixin AnalysisRuleWithFixes on AnalysisRule {
  List<ProducerGenerator> get fixes;

  void registerFixes(PluginRegistry registry) {
    if (diagnosticCode case final LintCode code) {
      for (final fix in fixes) {
        registry.registerFixForRule(code, fix);
      }
    }
  }
}
