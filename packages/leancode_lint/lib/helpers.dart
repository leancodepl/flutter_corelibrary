import 'package:analyzer/dart/ast/ast.dart';

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

/// Returns all return expressions from passed statement recursively.
Iterable<Expression> getAllInnerReturnStatements(Statement statement) {
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
      return getAllInnerReturnStatements(statement);

    case ReturnStatement():
      return [
        if (statement.expression case final expression?) expression,
      ];

    default:
      return [];
  }
}
