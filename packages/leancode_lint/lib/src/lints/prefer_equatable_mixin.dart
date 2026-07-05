import 'package:analysis_server_plugin/edit/dart/correction_producer.dart';
import 'package:analysis_server_plugin/edit/dart/dart_fix_kind_priority.dart';
import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/error/error.dart';
import 'package:analyzer_plugin/utilities/change_builder/change_builder_core.dart';
import 'package:analyzer_plugin/utilities/fixes/fixes.dart';
import 'package:analyzer_plugin/utilities/range_factory.dart';
import 'package:leancode_lint/src/type_checker.dart';

class PreferEquatableMixin extends AnalysisRule {
  PreferEquatableMixin()
    : super(name: code.lowerCaseName, description: code.problemMessage);

  static const code = LintCode(
    'prefer_equatable_mixin',
    'The class {0} should mix in {1} instead of extending Equatable.',
    correctionMessage: 'Replace with a mixin.',
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

  static const equatable = TypeChecker.fromName(
    'Equatable',
    packageName: 'equatable',
  );
  static const equatableMixin = TypeChecker.fromName(
    'EquatableMixin',
    packageName: 'equatable',
  );

  @override
  void visitClassDeclaration(ClassDeclaration node) {
    final extendsClause = node.extendsClause;
    if (extendsClause == null) {
      return;
    }

    final superType = extendsClause.superclass.type;
    final isEquatable = superType != null && equatable.isExactlyType(superType);

    final isEquatableMixin =
        node.withClause?.mixinTypes
            .map((mixin) => mixin.type)
            .nonNulls
            .any(equatableMixin.isExactlyType) ??
        false;

    if (isEquatable && !isEquatableMixin) {
      rule.reportAtNode(
        extendsClause.superclass,
        arguments: [
          node.namePart.typeName.lexeme,
          _recommendedMixinName(extendsClause.superclass),
        ],
      );
    }
  }
}

/// Recommends `Equatable` for `equatable` >= 2.1.0 (where it's a `mixin class`)
/// and the deprecated `EquatableMixin` for older versions.
String _recommendedMixinName(NamedType equatableType) =>
    switch (equatableType.element) {
      ClassElement(isMixinClass: true) => 'Equatable',
      _ => 'EquatableMixin',
    };

class ConvertToEquatableMixin extends ResolvedCorrectionProducer {
  ConvertToEquatableMixin({required super.context});

  @override
  FixKind get fixKind => const .new(
    'leancode_lint.fix.convertToEquatableMixin',
    DartFixKindPriority.standard,
    'Convert to a mixin',
  );

  @override
  CorrectionApplicability get applicability => .automatically;

  @override
  Future<void> compute(ChangeBuilder builder) async {
    final classDeclaration = node.thisOrAncestorOfType<ClassDeclaration>()!;
    final extendsClause = classDeclaration.extendsClause!;
    final withClause = classDeclaration.withClause;
    final mixinName = _recommendedMixinName(extendsClause.superclass);

    await builder.addDartFileEdit(file, (builder) {
      if (withClause != null) {
        builder
          ..addSimpleReplacement(
            range.startStart(extendsClause, withClause),
            '',
          )
          ..addSimpleInsertion(
            withClause.mixinTypes.first.offset,
            '$mixinName, ',
          );
      } else {
        builder.addSimpleReplacement(
          extendsClause.sourceRange,
          'with $mixinName',
        );
      }
    });
  }
}
