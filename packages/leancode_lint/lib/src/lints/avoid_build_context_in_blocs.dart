import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
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
    : super(
        name: code.lowerCaseName,
        description: "Avoid letting a 'BuildContext' cross into a Bloc/Cubit.",
      );

  static const code = LintCode(
    'avoid_build_context_in_blocs',
    // The specific clause is supplied per report site via `arguments`.
    '{0}',
    correctionMessage:
        "Business logic shouldn't depend on the widget tree. Pass only the data the Bloc/Cubit needs.",
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

const _passingMessage = "Avoid passing 'BuildContext' to a Bloc/Cubit.";

String _parameterMessage(BlocType type) => switch (type) {
  .bloc => "Avoid declaring 'BuildContext' parameters for Blocs.",
  .cubit => "Avoid declaring 'BuildContext' parameters for Cubits.",
};

String _fieldMessage(BlocType type) => switch (type) {
  .bloc => "Avoid declaring 'BuildContext' fields in Blocs.",
  .cubit => "Avoid declaring 'BuildContext' fields in Cubits.",
};

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
    final targetType = node.realTarget?.staticType;
    if (targetType == null || determineBlocType(targetType.element) == null) {
      return;
    }

    _reportContextArguments(node.argumentList);
  }

  // Passing side: `CounterCubit(context)` / `CounterBloc(context)`.
  @override
  void visitInstanceCreationExpression(InstanceCreationExpression node) {
    if (determineBlocType(node.staticType?.element) == null) {
      return;
    }

    _reportContextArguments(node.argumentList);
  }

  // Declaration side: `BuildContext` parameters and fields inside a Bloc/Cubit.
  @override
  void visitClassDeclaration(ClassDeclaration node) {
    final element = node.declaredFragment?.element;
    final blocType = determineBlocType(element);
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
      final name = parameter.name;
      final type = parameter.declaredFragment?.element.type;
      if (name != null && type != null && _isBuildContext(type)) {
        rule.reportAtToken(name, arguments: [_parameterMessage(blocType)]);
      }
    }
  }

  void _checkFields(VariableDeclarationList fields, BlocType blocType) {
    for (final variable in fields.variables) {
      final type = variable.declaredFragment?.element.type;
      if (type != null && _isBuildContext(type)) {
        rule.reportAtToken(variable.name, arguments: [_fieldMessage(blocType)]);
      }
    }
  }

  void _reportContextArguments(ArgumentList argumentList) {
    for (final argument in argumentList.arguments) {
      final expression = argument.argumentExpression;
      if (_carriesContext(expression, {}, 0)) {
        rule.reportAtNode(expression, arguments: [_passingMessage]);
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

    final type = expression.staticType;
    if (type != null && _isBuildContext(type)) {
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
      case SimpleIdentifier(:final Element element?)
          when element is LocalVariableElement && visited.add(element):
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
class _InitializerFinder extends RecursiveAstVisitor<void> {
  _InitializerFinder(this.element);

  final LocalVariableElement element;
  Expression? initializer;

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
