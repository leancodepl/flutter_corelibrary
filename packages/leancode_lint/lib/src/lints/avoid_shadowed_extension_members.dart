/*
 * AI-Provenance:
 *   model: claude-fable-5-1
 *   harness: Claude Code
 */

import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:analyzer/error/error.dart';

/// Reports an extension member that an instance member of the extension's
/// `on` type shadows.
///
/// When the receiver's static type has an instance member with the same base
/// name as an extension member (a getter `x`, a setter `x=` or a method `x`,
/// whichever kind either of them is), the instance member always wins: the
/// extension member is only reachable through an explicit extension override
/// such as `MyExtension(receiver).x`, and every call that looks like a call of
/// it calls the instance member instead. Such a member is almost always a
/// mistake, e.g. one written before the `on` type gained the member itself, and
/// tests of it silently test the instance member.
///
/// The `on` type's whole interface counts, inherited and abstract members
/// included; static members never shadow. For a type parameter the bound's
/// interface counts, and a nullable `on` type has only `Object`'s members. A
/// member named like one of `Object`'s is already a compile-time error, so it
/// is not reported again.
class AvoidShadowedExtensionMembers() extends AnalysisRule {
  this : super(name: code.lowerCaseName, description: code.problemMessage);

  static const code = LintCode(
    'avoid_shadowed_extension_members',
    "The extension {0} '{1}' is shadowed by the {2} '{3}', so it is only "
        'reachable through an explicit extension override.',
    correctionMessage: 'Rename the extension {0}, or remove it.',
    severity: .WARNING,
  );

  @override
  LintCode get diagnosticCode => code;

  @override
  void registerNodeProcessors(
    RuleVisitorRegistry registry,
    RuleContext context,
  ) {
    registry.addExtensionDeclaration(this, _Visitor(this, context));
  }
}

class _Visitor(final AnalysisRule rule, final RuleContext context)
    extends SimpleAstVisitor<void> {
  @override
  void visitExtensionDeclaration(ExtensionDeclaration node) {
    final extension = node.declaredFragment?.element;
    if (extension == null) {
      return;
    }

    final onType = _shadowingInterface(extension.extendedType);
    if (onType == null) {
      return;
    }

    if (node.body case BlockClassBody(:final members)) {
      for (final member in members.whereType<MethodDeclaration>()) {
        _checkMember(member, onType, extension.enclosingElement);
      }
    }
  }

  void _checkMember(
    MethodDeclaration member,
    InterfaceType onType,
    LibraryElement library,
  ) {
    final element = member.declaredFragment?.element;
    if (member.isStatic || element == null) {
      return;
    }

    // Shadowing goes by base name: a setter `x=` takes the name `x` as well,
    // while `unary-` and `-` are distinct operators.
    final baseName = switch (element) {
      MethodElement() => element.lookupName,
      _ => element.name,
    };
    if (baseName == null) {
      return;
    }

    // The analyzer already reports `extension_declares_member_of_object`.
    final objectElement = context.typeProvider.objectElement;
    if (objectElement.getMethod(baseName) != null ||
        objectElement.getGetter(baseName) != null) {
      return;
    }

    final getter = onType.lookUpGetter(baseName, library);
    final setter = onType.lookUpSetter(baseName, library);
    final method = onType.lookUpMethod(baseName, library);
    // Any of them shadows; the one of the same kind explains it best.
    final shadowing = switch (element) {
      GetterElement() => getter ?? setter ?? method,
      SetterElement() => setter ?? getter ?? method,
      _ => method ?? getter ?? setter,
    };
    if (shadowing == null) {
      return;
    }

    final owner = shadowing.enclosingElement ?? onType.element;
    rule.reportAtToken(
      member.name,
      arguments: [
        _kind(element),
        baseName,
        _kind(shadowing),
        '${owner.displayName}.$baseName',
      ],
    );
  }

  /// The interface whose instance members shadow the members of an extension
  /// on [onType], if there is one.
  ///
  /// A type parameter has its bound's interface. A nullable type has only
  /// `Object`'s members, and a function, record or special type has none that
  /// an extension could declare without a compile-time error.
  static InterfaceType? _shadowingInterface(DartType onType) {
    final visited = <TypeParameterElement>{};
    var type = onType;
    while (type.nullabilitySuffix == .none) {
      switch (type) {
        case InterfaceType():
          return type;
        case TypeParameterType(:final element, :final bound)
            when visited.add(element):
          type = bound;
        default:
          return null;
      }
    }
    return null;
  }

  static String _kind(ExecutableElement element) => switch (element) {
    PropertyAccessorElement(isOriginVariable: true) => 'field',
    GetterElement() => 'getter',
    SetterElement() => 'setter',
    MethodElement(isOperator: true) => 'operator',
    _ => 'method',
  };
}
