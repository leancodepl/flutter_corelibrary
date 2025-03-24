import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/error/error.dart';
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';
import 'package:leancode_lint/helpers.dart';

/// Displays warning for string literals used inside Widget classes.
class AvoidStringLiteralsInWidgets extends DartLintRule {
  AvoidStringLiteralsInWidgets() : super(code: _getLintCode());

  static const ruleName = 'avoid_string_literals_in_widgets';

  @override
  void run(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
  ) {
    context.registry.addClassDeclaration(
      (node) {
        final isThisWidgetClass = isWidgetClass(node);
        if (!isThisWidgetClass) {
          return;
        }

        final stringLiterals = _getDescendantStringLiterals(node);

        for (final stringLiteral in stringLiterals) {
          reporter.reportErrorForNode(_getLintCode(), stringLiteral);
        }
      },
    );
  }

  static List<AstNode> _getDescendantStringLiterals(
    AstNode node,
  ) {
    final stringLiterals = <StringLiteral>[];
    node.visitChildren(_StringLiteralVisitor(stringLiterals));
    return stringLiterals;
  }

  static LintCode _getLintCode() {
    return const LintCode(
      name: ruleName,
      problemMessage: 'Do not use string literals in widgets.',
      correctionMessage: 'Prefer a localized message.',
      errorSeverity: ErrorSeverity.WARNING,
    );
  }
}

class _StringLiteralVisitor extends GeneralizingAstVisitor<void> {
  _StringLiteralVisitor(this.acc);

  final List<StringLiteral> acc;

  @override
  void visitStringLiteral(StringLiteral node) {
    final insideCatchClause =
        node.thisOrAncestorMatching((n) => n is CatchClause) != null;
    final insideThrowExpression =
        node.thisOrAncestorMatching((n) => n is ThrowExpression) != null;
    if (!insideCatchClause && !insideThrowExpression) {
      acc.add(node);
    }

    super.visitStringLiteral(node);
  }
}
