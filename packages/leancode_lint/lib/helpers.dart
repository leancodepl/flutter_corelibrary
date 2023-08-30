import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/element/element.dart';

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

bool isHook(Expression expression) {
  const hookSuffix = 'use';

  switch (expression) {
    case FunctionExpression(declaredElement: ExecutableElement(:final name)):
      return name.startsWith(hookSuffix);

    case FunctionReference():
      return expression.toSource().startsWith(hookSuffix);

    case MethodInvocation(:final methodName):
      return methodName.name.startsWith(hookSuffix);

    case ConditionalExpression(:final thenExpression, :final elseExpression):
      return isHook(thenExpression) || isHook(elseExpression);

    default:
      return false;
  }
}

Iterable<Statement> getAllInnerHookStatements(Statement statement) {
  switch (statement) {
    case IfStatement():
      return [
        ...getAllInnerHookStatements(statement.thenStatement),
        if (statement.elseStatement case final statement?)
          ...getAllInnerHookStatements(statement),
      ];

    case ForStatement(:final body):
      return getAllInnerHookStatements(body);

    case Block():
      return statement.statements.expand(getAllInnerHookStatements);

    case TryStatement(:final body, :final catchClauses, :final finallyBlock):
      return [
        ...body.statements.expand(getAllInnerHookStatements),
        ...catchClauses
            .expand((clause) => clause.body.statements)
            .expand(getAllInnerHookStatements),
        ...?finallyBlock?.statements.expand(getAllInnerHookStatements),
      ];

    case DoStatement(:final body):
      return getAllInnerHookStatements(body);

    case WhileStatement(:final body):
      return getAllInnerHookStatements(body);

    case VariableDeclarationStatement():
      return [
        if (statement.variables.variables
            .map((variable) => variable.initializer)
            .nonNulls
            .any(isHook))
          statement,
      ];

    case ExpressionStatement():
      return [
        if (isHook(statement.expression)) statement,
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
