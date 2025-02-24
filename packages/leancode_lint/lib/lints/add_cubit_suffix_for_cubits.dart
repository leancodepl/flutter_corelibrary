import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/error/error.dart';
import 'package:analyzer/src/lint/linter.dart';
import 'package:leancode_lint/type_checker.dart';

/// Displays warning for cubits which do not have the `Cubit` suffix in their
/// class name.
class AddCubitSuffixForYourCubits extends AnalysisRule {
  AddCubitSuffixForYourCubits()
    : super(
        name: 'add_cubit_suffix_for_your_cubits',
        description: 'Add Cubit suffix for your cubits.',
      );

  @override
  LintCode get lintCode =>
      LintCode(name, description, correctionMessage: 'Ex. {0}Cubit');

  @override
  void registerNodeProcessors(
    NodeLintRegistry registry,
    LinterContext context,
  ) {
    registry.addClassDeclaration(this, _Visitor(this, context));
  }
}

class _Visitor extends SimpleAstVisitor<void> {
  _Visitor(this.rule, this.context);

  final LintRule rule;
  final LinterContext context;

  @override
  void visitClassDeclaration(ClassDeclaration node) {
    if (!_isCubitClass(node)) {
      return;
    }

    if (_hasCubitSuffix(node.name.lexeme)) {
      return;
    }

    rule.reportLintForToken(node.name, arguments: [node.name.lexeme]);
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
