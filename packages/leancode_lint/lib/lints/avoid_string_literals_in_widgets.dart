import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/error/error.dart';
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';
import 'package:leancode_lint/helpers.dart';

/// Displays warning for cubits which do not have the `Cubit` suffix in their
/// class name.
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

        final buildMethod = getBuildMethod(node);
        if (buildMethod == null) {
          return;
        }

        final stringLiterals = _getDescendantStringLiterals(node);

        for (final stringLiteral in stringLiterals) {
          reporter.reportErrorForNode(_getLintCode(), stringLiteral);
        }
      },
    );
  }

  static List<AstNode> _getDescendantStringLiterals(node) {
    return [];
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
