import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/token.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:analyzer/error/error.dart';
import 'package:leancode_lint/src/bloc_utils.dart';
import 'package:leancode_lint/src/type_checker.dart';

/// Warns when a `BuildContext` crosses into a Bloc/Cubit.
///
/// A `BuildContext` couples business logic to the widget tree, which risks
/// stale contexts and wrong `InheritedWidget` reads and makes the logic hard to
/// test. This rule flags a `BuildContext` on both sides of the boundary:
/// passing one into a Bloc/Cubit (via a method, e.g. `bloc.add(...)`, or a
/// constructor) and declaring one inside a Bloc/Cubit (as a parameter or field).
class AvoidBuildContextInBlocs extends AnalysisRule {
  AvoidBuildContextInBlocs()
    : super(name: code.lowerCaseName, description: code.problemMessage);

  static const code = LintCode(
    'avoid_build_context_in_blocs',
    "Avoid {0} a 'BuildContext' {1} a {2}.",
    correctionMessage:
        "Remove the 'BuildContext' and pass only the data the {2} needs.",
    severity: .WARNING,
  );

  @override
  LintCode get diagnosticCode => code;

  @override
  void registerNodeProcessors(
    RuleVisitorRegistry registry,
    RuleContext context,
  ) {
    final visitor = _Visitor(this);
    registry
      ..addMethodInvocation(this, visitor)
      ..addInstanceCreationExpression(this, visitor)
      ..addClassDeclaration(this, visitor);
  }
}

class _Visitor extends SimpleAstVisitor<void> {
  _Visitor(this.rule);

  final AnalysisRule rule;

  static const _buildContextChecker = TypeChecker.fromName(
    'BuildContext',
    packageName: 'flutter',
  );

  // Passing side: `bloc.add(...)` and other method calls on a Bloc/Cubit.
  @override
  void visitMethodInvocation(MethodInvocation node) {
    final blocType = determineBlocType(node.realTarget?.staticType?.element);
    if (blocType == null) {
      return;
    }

    _reportContextArguments(node.argumentList, blocType);
  }

  // Passing side: `CounterCubit(context)` / `CounterBloc(context)`.
  @override
  void visitInstanceCreationExpression(InstanceCreationExpression node) {
    final blocType = determineBlocType(node.staticType?.element);
    if (blocType == null) {
      return;
    }

    _reportContextArguments(node.argumentList, blocType);
  }

  // Declaration side: `BuildContext` parameters and fields inside a Bloc/Cubit.
  @override
  void visitClassDeclaration(ClassDeclaration node) {
    final blocType = determineBlocType(node.declaredFragment?.element);
    if (blocType == null) {
      return;
    }

    final members = switch (node.body) {
      BlockClassBody(:final members) => members,
      _ => const <ClassMember>[],
    };

    for (final member in members) {
      switch (member) {
        case MethodDeclaration(:final parameters?):
          _checkParameters(parameters, blocType);
        case ConstructorDeclaration(:final parameters):
          _checkParameters(parameters, blocType);
        case FieldDeclaration(:final fields):
          _checkFields(fields, blocType);
        case _:
          break;
      }
    }
  }

  void _checkParameters(FormalParameterList parameters, BlocType blocType) {
    for (final parameter in parameters.parameters) {
      if (parameter case FormalParameter(
        :final name?,
        declaredFragment: final fragment?,
      ) when _isBuildContext(fragment.element.type)) {
        rule.reportAtToken(
          name,
          arguments: ['declaring', 'parameter in', blocType.name],
        );
      }
    }
  }

  void _checkFields(VariableDeclarationList fields, BlocType blocType) {
    for (final variable in fields.variables) {
      final type = variable.declaredFragment?.element.type;
      if (type != null && _isBuildContext(type)) {
        rule.reportAtToken(
          variable.name,
          arguments: ['declaring', 'field in', blocType.name],
        );
      }
    }
  }

  void _reportContextArguments(ArgumentList argumentList, BlocType blocType) {
    for (final argument in argumentList.arguments) {
      final expression = argument.argumentExpression;
      if (_carriesContext(expression, {}, 0)) {
        rule.reportAtNode(
          expression,
          arguments: ['passing', 'to', blocType.name],
        );
      }
    }
  }

  /// Whether [expression] carries a `BuildContext` into the enclosing call.
  ///
  /// Returns true when the expression is itself a `BuildContext`, when it
  /// constructs an object with a `BuildContext` argument (e.g. an event like
  /// `CounterEvent(context)`, including nested constructions), or when it is a
  /// local variable whose initializer does so. Recursion deliberately does not
  /// descend into method/function calls, so a value merely *derived* from a
  /// context (e.g. `MediaQuery.sizeOf(context)`) is not flagged.
  ///
  /// The local-variable trace is best-effort: it only inspects the declaration
  /// initializer, not later reassignments. [visited] guards against cycles.
  bool _carriesContext(
    Expression? expression,
    Set<Element> visited,
    int depth,
  ) {
    if (expression == null || depth > 20) {
      return false;
    }

    if (expression.staticType case final type? when _isBuildContext(type)) {
      return true;
    }

    switch (expression) {
      case InstanceCreationExpression(:final argumentList):
        for (final argument in argumentList.arguments) {
          if (_carriesContext(
            argument.argumentExpression,
            visited,
            depth + 1,
          )) {
            return true;
          }
        }
      case ParenthesizedExpression(:final expression):
      case AsExpression(:final expression):
        return _carriesContext(expression, visited, depth + 1);
      case PostfixExpression(:final operand, :final operator)
          when operator.type == TokenType.BANG:
        return _carriesContext(operand, visited, depth + 1);
      case SimpleIdentifier(:final LocalVariableElement element?)
          when visited.add(element):
        final initializer = _localVariableInitializer(expression, element);
        if (_carriesContext(initializer, visited, depth + 1)) {
          return true;
        }
    }

    return false;
  }

  Expression? _localVariableInitializer(
    AstNode reference,
    LocalVariableElement element,
  ) {
    AstNode? body = reference;
    while (body != null && body is! FunctionBody) {
      body = body.parent;
    }
    if (body == null) {
      return null;
    }

    final finder = _InitializerFinder(element);
    body.accept(finder);
    return finder.initializer;
  }

  bool _isBuildContext(DartType type) =>
      _buildContextChecker.isExactlyType(type);
}

/// Finds the declaration initializer of a specific [LocalVariableElement].
class _InitializerFinder extends GeneralizingAstVisitor<void> {
  _InitializerFinder(this.element);

  final LocalVariableElement element;
  Expression? initializer;

  @override
  void visitNode(AstNode node) {
    if (initializer == null) {
      super.visitNode(node);
    }
  }

  @override
  void visitVariableDeclaration(VariableDeclaration node) {
    if (initializer == null &&
        node.declaredFragment?.element == element &&
        node.initializer != null) {
      initializer = node.initializer;
    }
    super.visitVariableDeclaration(node);
  }
}
