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
  if (body
      case ExpressionFunctionBody(:final expression) ||
          BlockFunctionBody(
            block: Block(statements: [ReturnStatement(:final expression?)])
          )) {
    return expression;
  }
  return null;
}
