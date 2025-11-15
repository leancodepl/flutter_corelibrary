import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/error/error.dart';

/// Displays warning when constructor's parameters' order vary from class
/// declared fields order. Works for the both named and unnamed parameters.
class ConstructorParametersAndFieldsShouldHaveTheSameOrder
    extends AnalysisRule {
  ConstructorParametersAndFieldsShouldHaveTheSameOrder()
    : super(
        name: code.name,
        description:
            'Keep the API predictable by keeping the order of constructor parameters '
            'aligned with the declaration order of class fields. '
            'This applies to both named and positional parameters, '
            'making code easier to read and initialize correctly.',
      );

  static const code = LintCode(
    'constructor_parameters_and_fields_should_have_the_same_order',
    'The order of constructor parameters does not match the order of class fields.',
    correctionMessage:
        'Reorder the constructor parameters to match the order of the class fields.',
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
    final fields = node.members.whereType<FieldDeclaration>().toList();

    if (fields.isEmpty) {
      return;
    }

    final constructors = node.members.whereType<ConstructorDeclaration>();
    for (final constructor in constructors) {
      if (!_hasValidOrder(constructor, fields)) {
        rule.reportAtNode(constructor);
      }
    }
  }

  bool _hasValidOrder(
    ConstructorDeclaration constructor,
    List<FieldDeclaration> fields,
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

    final fieldsWithNamedParameters = fields
        .where(
          (field) => namedParameters.any(
            (parameter) => _compareEffectiveNames(field, parameter),
          ),
        )
        .toList();

    final fieldsWithUnnamedParameters = fields
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
      !(parameter.declaredFragment?.element.isSuperFormal ?? false);

  bool _compareEffectiveNames(
    FieldDeclaration field,
    FormalParameter parameter,
  ) {
    final relevantField = field.fields.variables.first;

    final effectiveFieldName = relevantField.name.lexeme.startsWith('_')
        ? relevantField.name.lexeme.substring(1)
        : relevantField.name.lexeme;

    final effectiveParameterName =
        parameter.name?.lexeme.startsWith('_') ?? false
        ? parameter.name?.lexeme.substring(1)
        : parameter.name?.lexeme;

    return effectiveParameterName == effectiveFieldName;
  }
}
