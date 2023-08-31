import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

class ClassParametersAndFieldsShouldHaveTheSameOrder extends DartLintRule {
  ClassParametersAndFieldsShouldHaveTheSameOrder()
      : super(code: _getLintCode());

  static const ruleName =
      'class_parameters_and_fields_should_have_the_same_order';

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
            reporter.reportErrorForOffset(
              _getLintCode(),
              constructor.parameters.parameters.first.offset,
              constructor.parameters.parameters.last.offset +
                  constructor.parameters.parameters.last.length -
                  constructor.parameters.parameters.first.offset,
            );
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

    final namedParameters =
        parameters.where((parameter) => parameter.isNamed).toList();

    final unnamedParameters =
        parameters.where((parameter) => !parameter.isNamed).toList();

    final fieldsWithNamedParameters = fields
        .where(
          (field) => namedParameters.any(
            (parameter) {
              final relevantField = field.fields.variables.first;

              final effectiveFieldName =
                  relevantField.name.lexeme.startsWith('_')
                      ? relevantField.name.lexeme.substring(1)
                      : relevantField.name.lexeme;

              return parameter.name?.lexeme == effectiveFieldName;
            },
          ),
        )
        .toList();

    final fieldsWithUnnamedParameters = fields
        .where(
          (field) => unnamedParameters.any(
            (parameter) {
              final relevantField = field.fields.variables.first;

              final effectiveFieldName =
                  relevantField.name.lexeme.startsWith('_')
                      ? relevantField.name.lexeme.substring(1)
                      : relevantField.name.lexeme;

              return parameter.name?.lexeme == effectiveFieldName;
            },
          ),
        )
        .toList();

    for (var i = 0; i < namedParameters.length; i++) {
      final relevantField = fieldsWithNamedParameters[i].fields.variables.first;

      final effectiveFieldName = relevantField.name.lexeme.startsWith('_')
          ? relevantField.name.lexeme.substring(1)
          : relevantField.name.lexeme;

      if (namedParameters[i].name?.lexeme != effectiveFieldName) {
        return false;
      }
    }

    for (var i = 0; i < unnamedParameters.length; i++) {
      final relevantField =
          fieldsWithUnnamedParameters[i].fields.variables.first;

      final effectiveFieldName = relevantField.name.lexeme.startsWith('_')
          ? relevantField.name.lexeme.substring(1)
          : relevantField.name.lexeme;

      if (unnamedParameters[i].name?.lexeme != effectiveFieldName) {
        return false;
      }
    }

    return true;
  }

  static LintCode _getLintCode() => const LintCode(
        name: ruleName,
        problemMessage:
            'Class parameters and fields should have the same order.',
      );
}
