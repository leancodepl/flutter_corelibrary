import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/error/error.dart' hide LintCode;
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

/// Displays warning for cubits which do not have the `Cubit` suffix in their
/// class name.
class AddCubitSuffixForYourCubits extends DartLintRule {
  const AddCubitSuffixForYourCubits()
    : super(
        code: const LintCode(
          name: 'add_cubit_suffix_for_your_cubits',
          problemMessage: 'Add Cubit suffix for your cubits.',
          correctionMessage: 'Ex. {0}Cubit',
          errorSeverity: ErrorSeverity.WARNING,
        ),
      );

  @override
  void run(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
  ) {
    context.registry.addClassDeclaration((node) {
      final isCubitClass = _isCubitClass(node);
      if (!isCubitClass) {
        return;
      }

      final nameEndsWithCubit = _hasCubitSuffix(node.name.lexeme);
      if (nameEndsWithCubit) {
        return;
      }

      reporter.atToken(node.name, code, arguments: [node.name.lexeme]);
    });
  }

  bool _hasCubitSuffix(String className) => className.endsWith('Cubit');

  bool _isCubitClass(ClassDeclaration node) => switch (node.declaredElement) {
    final element? => const TypeChecker.fromName(
      'Cubit',
      packageName: 'bloc',
    ).isSuperOf(element),
    _ => false,
  };
}
