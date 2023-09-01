import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:collection/collection.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

String typeParametersString(
  Iterable<TypeParameter> typeParameters, {
  bool withBounds = false,
}) {
  final parameters =
      typeParameters.map((e) => withBounds ? e.toSource() : e.name).join(', ');

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
      block: Block(
        statements: [
          ReturnStatement(:final expression?),
        ],
      )
    ) =>
      expression,
    _ => null,
  };
}

Iterable<Expression> getAllInnerHookExpressions(Expression expression) {
  const hookPrefixes = ['use', '_use'];

  switch (expression) {
    case AwaitExpression(:final expression):
      return getAllInnerHookExpressions(expression);

    case SwitchExpression(:final cases):
      return cases.expand(
        (element) => getAllInnerHookExpressions(element.expression),
      );

    case FunctionExpression(
        :final body,
        declaredElement: ExecutableElement(:final name),
      ):
      if (hookPrefixes.any(name.startsWith)) {
        return [expression];
      }

      return switch (body) {
        ExpressionFunctionBody(:final expression) =>
          getAllInnerHookExpressions(expression),
        BlockFunctionBody(:final block)
            when block.statements
                .expand(getAllStatementsContainingHooks)
                .isNotEmpty =>
          [expression],
        _ => [],
      };

    case FunctionReference():
      return [
        if (hookPrefixes.any(expression.toSource().startsWith)) expression,
      ];

    case MethodInvocation(:final methodName):
      return [
        if (hookPrefixes.any(methodName.name.startsWith)) expression,
      ];

    case FunctionExpressionInvocation(:final function):
      return getAllInnerHookExpressions(function);

    case AssignmentExpression(:final rightHandSide):
      return getAllInnerHookExpressions(rightHandSide);

    case InvocationExpression(:final function):
      return getAllInnerHookExpressions(function);

    case ConditionalExpression(:final thenExpression, :final elseExpression):
      return [
        ...getAllInnerHookExpressions(thenExpression),
        ...getAllInnerHookExpressions(elseExpression),
      ];

    case NullShortableExpression(:final nullShortingTermination):
      return getAllInnerHookExpressions(nullShortingTermination);

    case ParenthesizedExpression(:final expression):
      return getAllInnerHookExpressions(expression);

    case InstanceCreationExpression():
      return [];

    default:
      return [];
  }
}

Iterable<Statement> getAllStatementsContainingHooks(Statement statement) {
  switch (statement) {
    case IfStatement():
      return [
        ...getAllStatementsContainingHooks(statement.thenStatement),
        if (statement.elseStatement case final statement?)
          ...getAllStatementsContainingHooks(statement),
      ];

    case ForStatement(:final body):
      return getAllStatementsContainingHooks(body);

    case Block():
      return statement.statements.expand(getAllStatementsContainingHooks);

    case TryStatement(:final body, :final catchClauses, :final finallyBlock):
      return [
        ...body.statements.expand(getAllStatementsContainingHooks),
        ...catchClauses
            .expand((clause) => clause.body.statements)
            .expand(getAllStatementsContainingHooks),
        ...?finallyBlock?.statements.expand(getAllStatementsContainingHooks),
      ];

    case DoStatement(:final body):
      return getAllStatementsContainingHooks(body);

    case WhileStatement(:final body):
      return getAllStatementsContainingHooks(body);

    case VariableDeclarationStatement():
      return [
        if (statement.variables.variables
            .map((variable) => variable.initializer)
            .nonNulls
            .any(
              (expression) => getAllInnerHookExpressions(expression).isNotEmpty,
            ))
          statement,
      ];

    case ExpressionStatement():
      final hasHookExpressions =
          getAllInnerHookExpressions(statement.expression).isNotEmpty;

      return [
        if (hasHookExpressions) statement,
      ];

    default:
      return [];
  }
}

/// Returns all return expressions from passed statement recursively.
Iterable<Expression?> getAllInnerReturnStatements(Statement statement) {
  switch (statement) {
    case IfStatement():
      return [
        ...getAllInnerReturnStatements(statement.thenStatement),
        if (statement.elseStatement case final statement?)
          ...getAllInnerReturnStatements(statement),
      ];

    case ForStatement(:final body):
      return getAllInnerReturnStatements(body);

    case Block():
      return statement.statements.expand(getAllInnerReturnStatements);

    case TryStatement(:final body, :final catchClauses, :final finallyBlock):
      return [
        ...body.statements.expand(getAllInnerReturnStatements),
        ...catchClauses
            .expand((clause) => clause.body.statements)
            .expand(getAllInnerReturnStatements),
        ...?finallyBlock?.statements.expand(getAllInnerReturnStatements),
      ];

    case DoStatement(:final body):
      return getAllInnerReturnStatements(body);

    case WhileStatement(:final body):
      return getAllInnerReturnStatements(body);

    case ExpressionStatement():
      return [];

    case ReturnStatement():
      return [statement.expression];

    default:
      return [];
  }
}

bool isWidgetClass(ClassDeclaration node) => switch (node.declaredElement) {
      final element? => const TypeChecker.any([
          TypeChecker.fromName('StatelessWidget', packageName: 'flutter'),
          TypeChecker.fromName('State', packageName: 'flutter'),
          TypeChecker.fromName('HookWidget', packageName: 'flutter_hooks'),
        ]).isSuperOf(element),
      _ => false,
    };

MethodDeclaration? getBuildMethod(ClassDeclaration node) => node.members
    .whereType<MethodDeclaration>()
    .firstWhereOrNull((member) => member.name.lexeme == 'build');
