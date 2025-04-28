import 'package:analyzer/error/error.dart' hide LintCode;
import 'package:analyzer/error/listener.dart';
import 'package:analyzer/source/source_range.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

class UseEquatableMixin extends DartLintRule {
  const UseEquatableMixin()
      : super(
          code: const LintCode(
            name: 'prefer_equatable_mixin',
            problemMessage:
                'The class {0} should mix in EquatableMixin instead of extending Equatable.',
            errorSeverity: ErrorSeverity.WARNING,
          ),
        );

  static const typeCheckers = (
    equatable: TypeChecker.fromName('Equatable', packageName: 'equatable'),
    equatableMixin:
        TypeChecker.fromName('EquatableMixin', packageName: 'equatable'),
  );

  @override
  List<Fix> getFixes() => [ConvertToMixin()];

  @override
  void run(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
  ) {
    context.registry.addClassDeclaration((node) {
      final extendsClause = node.extendsClause;
      if (extendsClause == null) {
        return;
      }

      final superType = extendsClause.superclass.type;
      final isEquatable =
          superType != null && typeCheckers.equatable.isExactlyType(superType);

      final isEquatableMixin = node.withClause?.mixinTypes
              .map((mixin) => mixin.type)
              .nonNulls
              .any(typeCheckers.equatableMixin.isExactlyType) ??
          false;

      if (isEquatable && !isEquatableMixin) {
        reporter.atNode(
          extendsClause.superclass,
          code,
          arguments: [node.name.lexeme],
          data: extendsClause.sourceRange,
        );
      }
    });
  }
}

class ConvertToMixin extends DartFix {
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
      message: 'Replace with a mixin',
      priority: 1,
    )
        .addDartFileEdit((builder) {
      builder.addSimpleReplacement(
        analysisError.data! as SourceRange,
        'with EquatableMixin',
      );
    });
  }
}
