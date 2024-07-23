import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/error/error.dart';
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

/// Displays warning when constructor's parameters' order vary from class
/// declared fields order. Works for the both named and unnamed parameters.
class ConstructorParametersAndFieldsShouldHaveTheSameOrder
    extends DartLintRule {
  ConstructorParametersAndFieldsShouldHaveTheSameOrder()
      : super(code: _getLintCode());

  static const ruleName =
      'constructor_parameters_and_fields_should_have_the_same_order';

  // TODO: disabled until stabilized. Add documentation.
  @override
  bool get enabledByDefault => false;

  @override
  void run(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
  ) {
    context.registry.addClassDeclaration(
      (node) {
        final fields = node.members.whereType<FieldDeclaration>().toList();

        if (fields.isEmpty) {
          return;
        }

        final constructors = node.members.whereType<ConstructorDeclaration>();
        for (final constructor in constructors) {
          if (!_hasValidOrder(constructor, fields)) {
            reporter.reportErrorForNode(_getLintCode(), constructor);
          }
        }
      },
    );
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

    for (var i = 0;
        i < namedParameters.length && i < fieldsWithNamedParameters.length;
        i++) {
      if (!_compareEffectiveNames(
        fieldsWithNamedParameters[i],
        namedParameters[i],
      )) {
        return false;
      }
    }

    for (var i = 0;
        i < unnamedParameters.length && i < fieldsWithUnnamedParameters.length;
        i++) {
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
      !(parameter.declaredElement?.isSuperFormal ?? false);

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

  static LintCode _getLintCode() => const LintCode(
        name: ruleName,
        problemMessage:
            'Class parameters and fields should have the same order.',
        errorSeverity: ErrorSeverity.WARNING,
      );
}
