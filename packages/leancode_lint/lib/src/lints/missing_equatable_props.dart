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
import 'package:leancode_lint/src/helpers.dart';
import 'package:leancode_lint/src/type_checker.dart';
import 'package:leancode_lint/src/utils.dart';

/// Reports missing entries in a class's overridden Equatable `props` getter.
///
/// Every non-static field declared in the class must be referenced in the
/// `props` list literal. When the class extends another Equatable-like class,
/// `...super.props` must also be present so that inherited fields participate
/// in equality.
class MissingEquatableProps extends AnalysisRule {
  MissingEquatableProps()
    : super(name: code.lowerCaseName, description: code.problemMessage);

  static const code = LintCode(
    'missing_equatable_props',
    "The following are missing from Equatable's props: {0}.",
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

const _equatableTypeChecker = TypeChecker.any([
  TypeChecker.fromName('Equatable', packageName: 'equatable'),
  TypeChecker.fromName('EquatableMixin', packageName: 'equatable'),
]);

class _Visitor extends SimpleAstVisitor<void> {
  _Visitor(this.rule, this.context);

  final AnalysisRule rule;
  final RuleContext context;

  @override
  void visitClassDeclaration(ClassDeclaration node) {
    final element = node.declaredFragment?.element;
    if (element == null || !_equatableTypeChecker.isAssignableFrom(element)) {
      return;
    }

    final members = _getMembers(node);
    final propsGetter = _findPropsGetter(members);
    if (propsGetter == null) {
      return;
    }

    final listLiteral = _getPropsListLiteral(propsGetter);
    if (listLiteral == null) {
      return;
    }

    final contents = _collectExistingProps(listLiteral);
    if (contents.hasUnrecognizedContent) {
      return;
    }

    final missing = _findMissingPropEntries(
      element: element,
      members: members,
      contents: contents,
    );
    if (missing.isEmpty) {
      return;
    }

    rule.reportAtNode(listLiteral, arguments: [missing.join(', ')]);
  }
}

/// Inserts every missing entry into the `props` list.
///
/// `...super.props` is inserted at the start of the list; missing fields are
/// appended at the end, preserving declaration order.
class AddToEquatablePropsFix extends ResolvedCorrectionProducer {
  AddToEquatablePropsFix({required super.context});

  @override
  FixKind? get fixKind => const FixKind(
    'leancode_lint.fix.addToEquatableProps',
    DartFixKindPriority.standard,
    'Add all missing entries to props',
  );

  @override
  CorrectionApplicability get applicability =>
      CorrectionApplicability.automatically;

  @override
  Future<void> compute(ChangeBuilder builder) async {
    final classDecl = node.thisOrAncestorOfType<ClassDeclaration>();
    if (classDecl == null) {
      return;
    }
    final element = classDecl.declaredFragment?.element;
    if (element == null) {
      return;
    }

    final members = _getMembers(classDecl);
    final propsGetter = _findPropsGetter(members);
    if (propsGetter == null) {
      return;
    }

    final listLiteral = _getPropsListLiteral(propsGetter);
    if (listLiteral == null) {
      return;
    }

    final contents = _collectExistingProps(listLiteral);
    if (contents.hasUnrecognizedContent) {
      return;
    }

    final needsSuper =
        _shouldHaveSuperProps(element) && !contents.hasSuperPropsSpread;
    final missingFields = _findMissingFieldNames(members, contents.names);

    if (!needsSuper && missingFields.isEmpty) {
      return;
    }

    await builder.addDartFileEdit(file, (builder) {
      if (listLiteral.elements.isEmpty) {
        final text = [
          if (needsSuper) '...super.props',
          ...missingFields,
        ].join(', ');
        builder.addSimpleInsertion(listLiteral.leftBracket.end, text);
        return;
      }

      if (needsSuper) {
        builder.addSimpleInsertion(
          listLiteral.elements.first.offset,
          '...super.props, ',
        );
      }
      if (missingFields.isNotEmpty) {
        builder.addSimpleInsertion(
          listLiteral.elements.last.end,
          ', ${missingFields.join(', ')}',
        );
      }
    });
  }
}

List<ClassMember> _getMembers(ClassDeclaration node) => switch (node.body) {
  BlockClassBody(:final members) => members,
  _ => const <ClassMember>[],
};

MethodDeclaration? _findPropsGetter(List<ClassMember> members) =>
    members.whereType<MethodDeclaration>().firstWhereOrNull(
      (m) => m.isGetter && m.name.lexeme == 'props',
    );

ListLiteral? _getPropsListLiteral(MethodDeclaration propsGetter) {
  final expression = maybeGetSingleReturnExpression(propsGetter.body);
  return expression is ListLiteral ? expression : null;
}

class _PropsListContents {
  const _PropsListContents({
    required this.names,
    required this.hasSuperPropsSpread,
    required this.hasUnrecognizedContent,
  });

  /// Names referenced in the list, including those written as `this.x`.
  final Set<String> names;

  /// Whether the list contains a `...super.props` spread.
  final bool hasSuperPropsSpread;

  /// `true` when the list contains expressions the rule cannot reason about
  /// (other spreads, if/for elements, method calls, …). In that case the
  /// lint should silently skip the class to avoid false positives.
  final bool hasUnrecognizedContent;
}

_PropsListContents _collectExistingProps(ListLiteral listLiteral) {
  final names = <String>{};
  var hasSuperPropsSpread = false;
  var hasUnrecognizedContent = false;

  for (final element in listLiteral.elements) {
    switch (element) {
      case SimpleIdentifier(:final name):
        names.add(name);
      case PropertyAccess(target: ThisExpression(), :final propertyName):
        names.add(propertyName.name);
      case SpreadElement(
        expression: PropertyAccess(
          target: SuperExpression(),
          propertyName: SimpleIdentifier(name: 'props'),
        ),
      ):
        hasSuperPropsSpread = true;
      default:
        hasUnrecognizedContent = true;
    }
  }

  return _PropsListContents(
    names: names,
    hasSuperPropsSpread: hasSuperPropsSpread,
    hasUnrecognizedContent: hasUnrecognizedContent,
  );
}

List<String> _findMissingPropEntries({
  required InterfaceElement element,
  required List<ClassMember> members,
  required _PropsListContents contents,
}) {
  final needsSuper =
      _shouldHaveSuperProps(element) && !contents.hasSuperPropsSpread;

  return [
    if (needsSuper) '...super.props',
    ..._findMissingFieldNames(members, contents.names),
  ];
}

List<String> _findMissingFieldNames(
  List<ClassMember> members,
  Set<String> existingNames,
) => [
  for (final fieldDecl in members.whereType<FieldDeclaration>())
    if (!fieldDecl.isStatic)
      for (final variable in fieldDecl.fields.variables)
        if (!existingNames.contains(variable.name.lexeme))
          variable.name.lexeme,
];

/// Whether the class's superclass is itself Equatable-shaped and therefore
/// likely contributes additional fields via its own `props` getter.
///
/// Returns `false` for classes that only mix in `EquatableMixin` (their
/// supertype is [Object], which has no `props`) and for classes that extend
/// `Equatable` directly (its default `props` is empty, so spreading it is a
/// no-op).
bool _shouldHaveSuperProps(InterfaceElement element) {
  final supertype = element.supertype;
  if (supertype == null) {
    return false;
  }
  final supertypeElement = supertype.element;
  if (_equatableTypeChecker.isExactly(supertypeElement)) {
    return false;
  }
  return _equatableTypeChecker.isAssignableFrom(supertypeElement);
}
