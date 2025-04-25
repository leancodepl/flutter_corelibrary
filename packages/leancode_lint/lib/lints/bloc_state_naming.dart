import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/error/error.dart' hide LintCode;
import 'package:analyzer/error/listener.dart';
import 'package:collection/collection.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

class BlocStateNaming extends DartLintRule {
  const BlocStateNaming() : super(code: stateNameCode);

  static const stateNameCode = LintCode(
    name: 'bloc_state_base_name',
    problemMessage: "The name of {0}'s state should be {1}.",
    errorSeverity: ErrorSeverity.WARNING,
  );

  static const stateSealedCode = LintCode(
    name: 'bloc_state_sealed',
    problemMessage: 'The class {0} should be sealed.',
    errorSeverity: ErrorSeverity.WARNING,
  );

  static const stateFinalCode = LintCode(
    name: 'bloc_state_final',
    problemMessage: 'The class {0} should be final.',
    errorSeverity: ErrorSeverity.WARNING,
  );

  static const _allowedSuffixes = ['Initial', 'Loading', 'Success', 'Error'];
  static const subclassNameCode = LintCode(
    name: 'bloc_state_subclass_name',
    problemMessage:
        'The class {0} should end in one of the following suffixes: {1}.',
    errorSeverity: ErrorSeverity.WARNING,
  );

  static const equatableCode = LintCode(
    name: 'bloc_state_equatable',
    problemMessage: 'The class {0} should mix in EquatableMixin.',
    errorSeverity: ErrorSeverity.WARNING,
  );

  static const typeCheckers = (
    bloc: TypeChecker.fromName('BlocBase', packageName: 'bloc'),
    equatable: TypeChecker.fromName('Equatable', packageName: 'equatable'),
    equatableMixin:
        TypeChecker.fromName('EquatableMixin', packageName: 'equatable'),
  );

  @override
  void run(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
  ) {
    context.registry.addClassDeclaration((node) {
      final classElement = node.declaredElement;

      if (classElement == null ||
          !typeCheckers.bloc.isAssignableFrom(classElement)) {
        return;
      }

      final baseName =
          node.name.lexeme.replaceAll(RegExp(r'(Cubit|Bloc)$'), '');

      final stateType = classElement.allSupertypes
          .firstWhere((t) => typeCheckers.bloc.isExactly(t.element))
          .typeArguments
          .singleOrNull;
      if (stateType == null) {
        return;
      }

      final statePackage = stateType.element?.package;
      final blocPackage = classElement.package;

      if (statePackage == null ||
          blocPackage == null ||
          statePackage != blocPackage) {
        return;
      }

      final expectedStateName = '${baseName}State';

      if (stateType.element?.name != expectedStateName) {
        reporter.atToken(
          node.name,
          stateNameCode,
          arguments: [node.name.lexeme, expectedStateName],
        );
      }

      final stateElement = stateType.element;
      if (stateElement is! ClassElement) {
        return;
      }

      final subclasses = stateElement.subclasses;

      if (subclasses.isEmpty) {
        if (!stateElement.isFinal) {
          reporter.atElement(
            stateElement,
            stateFinalCode,
            arguments: [expectedStateName],
          );
        }
      } else {
        if (!stateElement.isSealed) {
          reporter.atElement(
            stateElement,
            stateSealedCode,
            arguments: [expectedStateName],
          );
        }
      }

      // TODO?
      // if (stateElement.isSealed) {
      //   final subtypes = stateElement.subclasses;
      //
      //   for (final subtype in subtypes) {
      //     if (_allowedSuffixes.none(subtype.name.endsWith)) {
      //       reporter.atElement(
      //         subtype,
      //         subclassNameCode,
      //         arguments: [expectedStateName, _allowedSuffixes.join(', ')],
      //       );
      //     }
      //   }
      // }

      final isEquatableMixin =
          stateElement.mixins.any(typeCheckers.equatableMixin.isExactlyType);

      if (!isEquatableMixin) {
        reporter.atElement(
          stateElement,
          equatableCode,
          arguments: [expectedStateName],
        );
      }
    });
  }
}

extension on Element {
  String? get package {
    final uri = library?.definingCompilationUnit.source.uri;
    if (uri == null || uri.scheme != 'package') {
      return null;
    }

    return uri.pathSegments.first;
  }
}

extension on ClassElement {
  Iterable<ClassElement> get subclasses {
    final thisTypeChecker = TypeChecker.fromStatic(thisType);
    return library.units.expand((u) => u.classes).where(
          (clazz) =>
              thisTypeChecker.isAssignableFrom(clazz) &&
              !thisTypeChecker.isExactly(clazz),
        );
  }
}
