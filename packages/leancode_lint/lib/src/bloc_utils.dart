import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:leancode_lint/src/type_checker.dart';

const blocChecker = TypeChecker.fromName('Bloc', packageName: 'bloc');

const cubitChecker = TypeChecker.fromName('Cubit', packageName: 'bloc');

const blocPresentationMixinChecker = TypeChecker.fromName(
  'BlocPresentationMixin',
  packageName: 'bloc_presentation',
);

String? getBlocSubject(String className, {required BlocType blocType}) =>
    switch (blocType) {
      .bloc when className.endsWith('Bloc') => className.substring(
        0,
        className.length - 4,
      ),
      .cubit when className.endsWith('Cubit') => className.substring(
        0,
        className.length - 5,
      ),
      _ => null,
    };

enum BlocType { bloc, cubit }

BlocType? determineBlocType(Element? element) {
  if (element == null) {
    return null;
  }

  if (blocChecker.isAssignableFrom(element)) {
    return .bloc;
  } else if (cubitChecker.isAssignableFrom(element)) {
    return .cubit;
  }

  return null;
}

class BlocInfo {
  const BlocInfo({
    required this.type,
    this.stateType,
    this.eventType,
    this.presentationEventType,
  });

  final BlocType type;
  final TypeAnnotation? stateType;
  final TypeAnnotation? eventType;
  final TypeAnnotation? presentationEventType;
}

BlocInfo? getBlocInfo(ClassDeclaration node) {
  final extendsClause = node.extendsClause;
  final superclass = extendsClause?.superclass;
  final superclassElement = superclass?.element;

  final type = determineBlocType(superclassElement);
  if (type == null) {
    return null;
  }

  final typeArguments = superclass?.typeArguments?.arguments;

  final (eventType, stateType) = switch (typeArguments) {
    [final state] when type == .cubit => (null, state),
    [final event, final state] when type == .bloc => (event, state),
    _ => (null, null),
  };

  TypeAnnotation? presentationEventType;
  if (node.withClause case final withClause?) {
    for (final mixin in withClause.mixinTypes) {
      if (mixin.element case final mixinElement?
          when blocPresentationMixinChecker.isExactly(mixinElement)) {
        if (mixin.typeArguments?.arguments case [_, final presentationEvent]) {
          presentationEventType = presentationEvent;
        }
      }
    }
  }

  return .new(
    type: type,
    stateType: stateType,
    eventType: eventType,
    presentationEventType: presentationEventType,
  );
}
