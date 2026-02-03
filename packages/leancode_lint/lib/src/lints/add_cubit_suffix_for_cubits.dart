import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/error/error.dart';
import 'package:leancode_lint/src/type_checker.dart';

/// Displays warning for cubits which do not have the `Cubit` suffix in their
/// class name.
class AddCubitSuffixForYourCubits extends AnalysisRule {
  AddCubitSuffixForYourCubits()
    : super(name: code.lowerCaseName, description: code.problemMessage);

  static const code = LintCode(
    'add_cubit_suffix_for_your_cubits',
    'Add Cubit suffix for your cubits.',
    correctionMessage: 'Ex. {0}Cubit',
    severity: .WARNING,
  );

  @override
  LintCode get diagnosticCode => code;

  @override
  void registerNodeProcessors(
    RuleVisitorRegistry registry,
    RuleContext context,
  ) {
    registry.addClassDeclaration(this, _Visitor(this, context));
  }
}

class _Visitor extends SimpleAstVisitor<void> {
  _Visitor(this.rule, this.context);

  final AnalysisRule rule;
  final RuleContext context;

  @override
  void visitClassDeclaration(ClassDeclaration node) {
    if (!_isCubitClass(node)) {
      return;
    }

    final name = node.namePart.typeName;

    if (_hasCubitSuffix(name.lexeme)) {
      return;
    }

    rule.reportAtToken(name, arguments: [name.lexeme]);
  }

  bool _hasCubitSuffix(String className) => className.endsWith('Cubit');

  bool _isCubitClass(ClassDeclaration node) =>
      switch (node.declaredFragment?.element) {
        final element? => const TypeChecker.fromName(
          'Cubit',
          packageName: 'bloc',
        ).isSuperOf(element),
        _ => false,
      };
}
