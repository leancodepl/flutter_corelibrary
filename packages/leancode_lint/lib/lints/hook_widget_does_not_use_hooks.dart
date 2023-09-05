import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/error/error.dart';
import 'package:analyzer/error/listener.dart';
import 'package:analyzer/source/source_range.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';
import 'package:leancode_lint/helpers.dart';

/// Displays warning when a `HookWidget` does not use hooks in the build method.
class HookWidgetDoesNotUseHooks extends DartLintRule {
  HookWidgetDoesNotUseHooks() : super(code: _getLintCode());

  static const ruleName = 'hook_widget_does_not_use_hooks';

  @override
  void run(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
  ) {
    context.registry.addClassDeclaration(
      (node) {
        final superclass = node.extendsClause?.superclass;
        final superclassElement = superclass?.element;
        if (superclass == null || superclassElement == null) {
          return;
        }

        final isDirectHookWidget = const TypeChecker.fromName(
          'HookWidget',
          packageName: 'flutter_hooks',
        ).isExactly(superclassElement);

        if (!isDirectHookWidget) {
          return;
        }

        final buildMethod = getBuildMethod(node);
        if (buildMethod == null) {
          return;
        }

        // get all hook  expressions from build method
        final hookExpressions = switch (buildMethod.body) {
          ExpressionFunctionBody(expression: final AstNode node) ||
          BlockFunctionBody(block: final AstNode node) =>
            getAllInnerHookExpressions(node),
          _ => <Expression>[],
        };

        if (hookExpressions.isNotEmpty) {
          return;
        }

        reporter.reportErrorForNode(_getLintCode(), superclass);
      },
    );
  }

  @override
  List<Fix> getFixes() => [
        _ConvertHookWidgetToStatelessWidget(),
      ];

  static LintCode _getLintCode() => const LintCode(
        name: ruleName,
        problemMessage: 'This HookWidget does not use hooks.',
        correctionMessage: 'Convert it to a StatelessWidget',
      );
}

class _ConvertHookWidgetToStatelessWidget extends DartFix {
  @override
  void run(
    CustomLintResolver resolver,
    ChangeReporter reporter,
    CustomLintContext context,
    AnalysisError analysisError,
    List<AnalysisError> others,
  ) {
    reporter
        .createChangeBuilder(
          message: 'Convert HookWidget to StatelessWidget',
          priority: 1,
        )
        .addDartFileEdit(
          (builder) => builder.addSimpleReplacement(
            SourceRange(analysisError.offset, analysisError.length),
            'StatelessWidget',
          ),
        );
  }
}
