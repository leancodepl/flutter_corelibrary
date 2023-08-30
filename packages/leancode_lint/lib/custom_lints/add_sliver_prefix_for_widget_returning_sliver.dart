// ignore_for_file: comment_references

import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/error/listener.dart';
import 'package:collection/collection.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

/// Displays warning for widgets returning slivers but not having [Sliver] or
/// [_Sliver] prefix.
class AddSliverPrefixForWidgetReturningSliver extends DartLintRule {
  AddSliverPrefixForWidgetReturningSliver() : super(code: _getLintCode());

  static const ruleName = 'add_sliver_prefix_for_widget_returning_sliver';

  @override
  void run(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
  ) {
    context.registry.addClassDeclaration(
      (node) {
        final isWidgetClass = _isWidgetClass(node);
        if (!isWidgetClass) {
          return;
        }

        final startsWithSliver = _hasSliverPrefix(node.name.lexeme);
        if (startsWithSliver) {
          return;
        }

        final buildMethod = _getBuildMethod(node);
        if (buildMethod == null) {
          return;
        }

        // Get all return expressions from build method
        final returnExpressions = switch (buildMethod.body) {
          ExpressionFunctionBody(:final expression) => [expression],
          BlockFunctionBody(:final block) =>
            block.statements.expand(_getAllInnerReturnStatements).toList(),
          _ => <Expression>[],
        };

        final isSliver = _anyReturnsSliver(returnExpressions);

        if (node case ClassDeclaration(:final declaredElement?) when isSliver) {
          reporter.reportErrorForElement(
            _getLintCode(node.name.lexeme),
            declaredElement,
          );
        }
      },
    );
  }

  /// Returns all return expressions from passed statement recursively.
  Iterable<Expression> _getAllInnerReturnStatements(Statement statement) {
    switch (statement) {
      case IfStatement():
        return [
          ..._getAllInnerReturnStatements(statement.thenStatement),
          if (statement.elseStatement case final statement?)
            ..._getAllInnerReturnStatements(statement),
        ];

      case ForStatement():
        return _getAllInnerReturnStatements(statement.body);

      case Block():
        return statement.statements.expand(_getAllInnerReturnStatements);

      case TryStatement():
        return [
          ...statement.body.statements.expand(_getAllInnerReturnStatements),
          ...statement.catchClauses
              .expand((clause) => clause.body.statements)
              .expand(_getAllInnerReturnStatements),
          ...?statement.finallyBlock?.statements
              .expand(_getAllInnerReturnStatements),
        ];

      case DoStatement():
        return _getAllInnerReturnStatements(statement.body);

      case WhileStatement():
        return _getAllInnerReturnStatements(statement.body);

      case ExpressionStatement():
        return _getAllInnerReturnStatements(statement);

      case ReturnStatement():
        return [
          if (statement.expression case final expression?) expression,
        ];

      default:
        return [];
    }
  }

  MethodDeclaration? _getBuildMethod(ClassDeclaration node) =>
      node.members.firstWhereOrNull(
        (member) =>
            member is MethodDeclaration && member.name.lexeme == 'build',
      ) as MethodDeclaration?;

  bool _hasSliverPrefix(String className) =>
      ['Sliver', '_Sliver'].any(className.startsWith);

  bool _anyReturnsSliver(Iterable<Expression> expressions) => expressions.any(
        (expression) =>
            expression is InstanceCreationExpression &&
            _hasSliverPrefix(expression.constructorName.type.name2.lexeme),
      );

  bool _isWidgetClass(ClassDeclaration node) => switch (node.declaredElement) {
        final element? => const TypeChecker.any([
            TypeChecker.fromName('StatelessWidget', packageName: 'flutter'),
            TypeChecker.fromName('State', packageName: 'flutter'),
          ]).isSuperOf(element),
        _ => false,
      };

  static LintCode _getLintCode([String? className]) {
    const problemMessageBase =
        'Add sliver prefix for widget that returns sliver in build method.';

    final exampleName = switch (className) {
      final name? when name.endsWith('State') =>
        name.replaceAll('_', '').replaceAll('State', ''),
      null => null,
      _ => className,
    };

    return LintCode(
      name: ruleName,
      problemMessage: problemMessageBase,
      correctionMessage: exampleName != null
          ? 'Ex. Sliver$exampleName or _Sliver$exampleName'
          : null,
    );
  }
}
