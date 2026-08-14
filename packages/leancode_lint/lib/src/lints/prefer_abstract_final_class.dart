import 'package:analysis_server_plugin/edit/dart/correction_producer.dart';
import 'package:analysis_server_plugin/edit/dart/dart_fix_kind_priority.dart';
import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/error/error.dart';
import 'package:analyzer/source/source_range.dart';
import 'package:analyzer_plugin/utilities/change_builder/change_builder_core.dart';
import 'package:analyzer_plugin/utilities/fixes/fixes.dart';
import 'package:analyzer_plugin/utilities/range_factory.dart';

class PreferAbstractFinalClass extends AnalysisRule {
  PreferAbstractFinalClass()
    : super(name: code.lowerCaseName, description: code.problemMessage);

  static const code = LintCode(
    'prefer_abstract_final_class',
    'The class {0} only holds static members and uses a private constructor to '
        'prevent instantiation; declare it as an `abstract final class` '
        'instead.',
    correctionMessage:
        'Mark the class as `abstract final` and remove the private '
        'constructor.',
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
    // Only a plain `class` is a candidate. Any existing class modifier
    // (`abstract`, `final`, `sealed`, `base`, `interface`, `mixin`) means the
    // author already made an intentional choice, or the transformation to
    // `abstract final class` doesn't apply.
    if (node.abstractKeyword != null ||
        node.finalKeyword != null ||
        node.sealedKeyword != null ||
        node.baseKeyword != null ||
        node.interfaceKeyword != null ||
        node.mixinKeyword != null ||
        node.augmentKeyword != null) {
      return;
    }

    // Must be a plain holder without any inheritance relationship.
    if (node.extendsClause != null ||
        node.withClause != null ||
        node.implementsClause != null) {
      return;
    }

    // A primary constructor is a guard only when it is the private `._()`;
    // anything else means the class is meant to be instantiated.
    final primaryConstructor = switch (node.namePart) {
      final PrimaryConstructorDeclaration primaryConstructor =>
        primaryConstructor,
      _ => null,
    };
    if (primaryConstructor != null &&
        !_isPrimaryInstantiationGuard(primaryConstructor)) {
      return;
    }

    ConstructorDeclaration? theConstructor;
    var constructorCount = primaryConstructor != null ? 1 : 0;
    var staticMemberCount = 0;

    for (final member in node.body.members) {
      switch (member) {
        case ConstructorDeclaration():
          constructorCount++;
          theConstructor = member;
        case FieldDeclaration(isStatic: true):
        case MethodDeclaration(isStatic: true):
          staticMemberCount++;
        default:
          // Any instance member (field, method, getter, setter, operator) or
          // any other unexpected member (including a primary constructor
          // `this` body) means this is not a pure static holder. Bail out to
          // avoid false positives.
          return;
      }
    }

    // Fire only when there is exactly one constructor, it is the private
    // instantiation-guard `_()`, and the class exposes at least one static
    // member (otherwise the transformation is pointless).
    if (constructorCount != 1 || staticMemberCount == 0) {
      return;
    }
    if (theConstructor != null && !_isInstantiationGuard(theConstructor)) {
      return;
    }

    rule.reportAtToken(
      node.namePart.typeName,
      arguments: [node.namePart.typeName.lexeme],
    );
  }

  /// Whether [ctor] is a private, unnamed-style `_()` constructor whose sole
  /// purpose is to prevent instantiation: named `_`, generative (not a
  /// factory), not external/augmenting, without parameters, initializers,
  /// redirection, or a non-empty body.
  static bool _isInstantiationGuard(ConstructorDeclaration ctor) {
    if (ctor.factoryKeyword != null ||
        ctor.externalKeyword != null ||
        ctor.augmentKeyword != null ||
        ctor.redirectedConstructor != null) {
      return false;
    }
    if (ctor.name?.lexeme != '_') {
      return false;
    }
    if (ctor.parameters.parameters.isNotEmpty) {
      return false;
    }
    if (ctor.initializers.isNotEmpty) {
      return false;
    }

    return switch (ctor.body) {
      EmptyFunctionBody() => true,
      BlockFunctionBody(:final block) => block.statements.isEmpty,
      _ => false,
    };
  }

  /// Whether [primaryConstructor] is a private `._()` primary constructor
  /// without parameters, serving only to prevent instantiation. A `this` body
  /// member (initializers or a body block) is rejected by the member loop.
  static bool _isPrimaryInstantiationGuard(
    PrimaryConstructorDeclaration primaryConstructor,
  ) =>
      primaryConstructor.constructorName?.name.lexeme == '_' &&
      primaryConstructor.formalParameters.parameters.isEmpty;
}

class ConvertToAbstractFinalClass extends ResolvedCorrectionProducer {
  ConvertToAbstractFinalClass({required super.context});

  @override
  FixKind get fixKind => const .new(
    'leancode_lint.fix.convertToAbstractFinalClass',
    DartFixKindPriority.standard,
    'Convert to an abstract final class',
  );

  @override
  CorrectionApplicability get applicability => .automatically;

  @override
  Future<void> compute(ChangeBuilder builder) async {
    final classDeclaration = node.thisOrAncestorOfType<ClassDeclaration>();
    if (classDeclaration == null) {
      return;
    }

    final List<SourceRange> deletions;
    switch (classDeclaration.namePart) {
      case PrimaryConstructorDeclaration(
        :final constKeyword,
        :final typeName,
        :final constructorName?,
        :final formalParameters,
      ):
        deletions = [
          if (constKeyword != null) range.startStart(constKeyword, typeName),
          range.startEnd(constructorName, formalParameters),
        ];
      case PrimaryConstructorDeclaration():
        return;
      case NameWithTypeParameters():
        final constructor = classDeclaration.body.members
            .whereType<ConstructorDeclaration>()
            .firstOrNull;
        if (constructor == null) {
          return;
        }
        deletions = [range.deletionRange(constructor)];
    }

    await builder.addDartFileEdit(file, (builder) {
      builder.addSimpleInsertion(
        classDeclaration.classKeyword.offset,
        'abstract final ',
      );
      deletions.forEach(builder.addDeletion);
    });
  }
}
