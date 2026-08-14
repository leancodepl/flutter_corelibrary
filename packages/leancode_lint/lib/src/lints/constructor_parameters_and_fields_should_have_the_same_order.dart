import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/error/error.dart';

/// Displays warning when constructor's parameters' order vary from class
/// declared fields order. Works for the both named and unnamed parameters.
class ConstructorParametersAndFieldsShouldHaveTheSameOrder
    extends AnalysisRule {
  ConstructorParametersAndFieldsShouldHaveTheSameOrder()
    : super(name: code.lowerCaseName, description: code.problemMessage);

  static const code = LintCode(
    'constructor_parameters_and_fields_should_have_the_same_order',
    'Class parameters and fields should have the same order.',
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
    final members = switch (node.body) {
      BlockClassBody(:final members) => members,
      _ => <ClassMember>[],
    };

    // Fields introduced by the primary constructor's declaring formal
    // parameters come before the fields declared in the class body.
    final fieldNames = [
      ..._primaryConstructorFieldNames(node),
      for (final field in members.whereType<FieldDeclaration>())
        _effectiveName(field.fields.variables.first.name.lexeme),
    ];

    if (fieldNames.isEmpty) {
      return;
    }

    final constructors = members.whereType<ConstructorDeclaration>();
    for (final constructor in constructors) {
      if (!_hasValidOrder(constructor, fieldNames)) {
        rule.reportAtNode(constructor);
      }
    }
  }

  List<String> _primaryConstructorFieldNames(ClassDeclaration node) => [
    if (node.namePart case PrimaryConstructorDeclaration(
      :final formalParameters,
    ))
      for (final parameter in formalParameters.parameters)
        if (parameter.declaredFragment?.element is FieldFormalParameterElement)
          if (parameter.name case final name?) _effectiveName(name.lexeme),
  ];

  bool _hasValidOrder(
    ConstructorDeclaration constructor,
    List<String> fieldNames,
  ) {
    final parameters = constructor.parameters.parameters;
    if (parameters.isEmpty) {
      return true;
    }

    final namedParameters = parameters
        .where((parameter) => parameter.isNamed && _isNotSuperFormal(parameter))
        .toList();

    final unnamedParameters = parameters
        .where(
          (parameter) => !parameter.isNamed && _isNotSuperFormal(parameter),
        )
        .toList();

    final fieldsWithNamedParameters = fieldNames
        .where(
          (field) => namedParameters.any(
            (parameter) => _compareEffectiveNames(field, parameter),
          ),
        )
        .toList();

    final fieldsWithUnnamedParameters = fieldNames
        .where(
          (field) => unnamedParameters.any(
            (parameter) => _compareEffectiveNames(field, parameter),
          ),
        )
        .toList();

    for (
      var i = 0;
      i < namedParameters.length && i < fieldsWithNamedParameters.length;
      i++
    ) {
      if (!_compareEffectiveNames(
        fieldsWithNamedParameters[i],
        namedParameters[i],
      )) {
        return false;
      }
    }

    for (
      var i = 0;
      i < unnamedParameters.length && i < fieldsWithUnnamedParameters.length;
      i++
    ) {
      if (!_compareEffectiveNames(
        fieldsWithUnnamedParameters[i],
        unnamedParameters[i],
      )) {
        return false;
      }
    }

    return true;
  }

  bool _isNotSuperFormal(FormalParameter parameter) =>
      parameter.declaredFragment?.element is! SuperFormalParameterElement;

  bool _compareEffectiveNames(
    String effectiveFieldName,
    FormalParameter parameter,
  ) {
    final effectiveParameterName = switch (parameter.name?.lexeme) {
      final name? => _effectiveName(name),
      null => null,
    };

    return effectiveParameterName == effectiveFieldName;
  }

  static String _effectiveName(String name) =>
      name.startsWith('_') ? name.substring(1) : name;
}
