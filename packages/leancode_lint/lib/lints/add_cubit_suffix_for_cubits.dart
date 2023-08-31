import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

/// Displays warning for cubits which do not have the `Cubit` suffix in their
/// class name.
class AddCubitSuffixForYourCubits extends DartLintRule {
  AddCubitSuffixForYourCubits() : super(code: _getLintCode());

  static const ruleName = 'add_cubit_suffix_for_your_cubits';

  @override
  void run(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
  ) {
    context.registry.addClassDeclaration(
      (node) {
        final isCubitClass = _isCubitClass(node);
        if (!isCubitClass) {
          return;
        }

        final nameEndsWithCubit = _hasCubitSuffix(node.name.lexeme);
        if (nameEndsWithCubit) {
          return;
        }

        if (node case ClassDeclaration(:final declaredElement?)) {
          reporter.reportErrorForElement(
            _getLintCode(node.name.lexeme),
            declaredElement,
          );
        }
      },
    );
  }

  bool _hasCubitSuffix(String className) => className.endsWith('Cubit');

  bool _isCubitClass(ClassDeclaration node) => switch (node.declaredElement) {
        final element? => const TypeChecker.fromName(
            'Cubit',
            packageName: 'bloc',
          ).isSuperOf(element),
        _ => false,
      };

  static LintCode _getLintCode([String? className]) {
    const problemMessageBase = 'Add Cubit suffix for your cubits.';

    final exampleName = switch (className) {
      final name? => '${name}Cubit',
      null => null,
    };

    return LintCode(
      name: ruleName,
      problemMessage: problemMessageBase,
      correctionMessage: exampleName != null ? 'Ex. $exampleName' : null,
    );
  }
}
