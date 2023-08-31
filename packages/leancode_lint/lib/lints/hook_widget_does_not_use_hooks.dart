import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/error/error.dart';
import 'package:analyzer/error/listener.dart';
import 'package:analyzer/source/source_range.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';
import 'package:leancode_lint/helpers.dart';

/// Displays warning when `HookWidget` does not use hooks in build method.
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
        final isHookWidget = switch (node.declaredElement) {
          final element? => const TypeChecker.any([
              TypeChecker.fromName('HookWidget', packageName: 'flutter_hooks'),
            ]).isSuperOf(element),
          _ => false,
        };

        if (!isHookWidget) {
          return;
        }

        final buildMethod = getBuildMethod(node);
        if (buildMethod == null) {
          return;
        }

        // Get all hook  expressions from build method
        final allHookExpressions = switch (buildMethod.body) {
          ExpressionFunctionBody(:final expression) => [
              if (isHook(expression)) expression,
            ],
          BlockFunctionBody(:final block) =>
            block.statements.expand(getAllInnerHookStatements).toList(),
          _ => <Expression>[],
        };

        if (allHookExpressions.isNotEmpty) {
          return;
        }

        final superclass = node.extendsClause!.superclass;

        reporter.reportErrorForOffset(
          _getLintCode(),
          superclass.offset,
          superclass.length,
        );
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
        correctionMessage: 'Convert it to StatelessWidget or StatefulWidget',
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
