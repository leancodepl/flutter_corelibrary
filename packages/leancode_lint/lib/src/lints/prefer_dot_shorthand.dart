import 'package:analysis_server_plugin/edit/dart/correction_producer.dart';
import 'package:analysis_server_plugin/edit/dart/dart_fix_kind_priority.dart';
import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/token.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/nullability_suffix.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:analyzer/dart/element/type_system.dart';
import 'package:analyzer/error/error.dart';
import 'package:analyzer/source/source_range.dart';
import 'package:analyzer_plugin/utilities/change_builder/change_builder_core.dart';
import 'package:analyzer_plugin/utilities/fixes/fixes.dart';
import 'package:analyzer_plugin/utilities/range_factory.dart';
import 'package:leancode_lint/config.dart';

/// Reports a static member, enum value or constructor spelled with its type
/// name where the context type already names that type, so a dot shorthand
/// would do: `.center` for `Alignment.center`, `.parse(s)` for
/// `int.parse(s)`, `.new(path, c)` for `Key(path, c)`.
///
/// The analyzer keeps no context types, so the rule derives them from the
/// expression's parent:
///
/// - an argument: the parameter's type, when its type parameters are pinned
///   by the receiver (`styles.add(.center)` on a `List<Alignment>`) or by the
///   invocation's own context rather than by the argument itself
/// - a typed variable's initializer, a default value, an assignment
/// - a `return` or `=>` against a declared return type; an `async` body
///   unwraps `Future<T>` and `FutureOr<T>`
/// - the right operand of `==` or `!=`, a constant pattern
/// - the branches of `??`, `?:` and a switch expression, parentheses
/// - a list, set or map literal whose type arguments or context fix the
///   element type
///
/// `T?` and `FutureOr<T>` resolve to `T`. Type arguments stay unless they
/// equal the context's. Annotation arguments are left alone: tools read
/// annotations with parsers of their own (`package:test` evaluates
/// `@Timeout(Duration(minutes: 1))` itself).
///
/// `LeanCodeLintConfig.preferDotShorthand` picks the kinds of member to
/// report: unnamed constructors, named constructors, static members and enum
/// values, all of them by default.
class PreferDotShorthand({required final PreferDotShorthandConfig config})
    extends AnalysisRule {
  this : super(name: code.lowerCaseName, description: code.problemMessage);

  static const code = LintCode(
    'prefer_dot_shorthand',
    "The context type is already '{0}'; a dot shorthand can leave it out.",
    correctionMessage: "Try replacing '{0}.{1}' with '.{1}'.",
    severity: .WARNING,
  );

  @override
  LintCode get diagnosticCode => code;

  @override
  void registerNodeProcessors(
    RuleVisitorRegistry registry,
    RuleContext context,
  ) {
    final visitor = _Visitor(this, config, context.typeSystem);
    registry
      ..addPrefixedIdentifier(this, visitor)
      ..addPropertyAccess(this, visitor)
      ..addMethodInvocation(this, visitor)
      ..addInstanceCreationExpression(this, visitor);
  }
}

class _Visitor(
  final AnalysisRule rule,
  final PreferDotShorthandConfig config,
  final TypeSystem typeSystem,
) extends SimpleAstVisitor<void> {
  @override
  void visitPrefixedIdentifier(PrefixedIdentifier node) => _check(node);

  @override
  void visitPropertyAccess(PropertyAccess node) => _check(node);

  @override
  void visitMethodInvocation(MethodInvocation node) => _check(node);

  @override
  void visitInstanceCreationExpression(InstanceCreationExpression node) =>
      _check(node);

  void _check(Expression node) {
    final qualified = qualifiedMemberOf(node);
    if (qualified == null || !_reports(qualified.kind)) {
      return;
    }
    final context = contextTypeOf(node);
    if (context == null) {
      return;
    }
    final namespace = namespaceOf(context, typeSystem);
    if (namespace == null || namespace.element != qualified.type) {
      return;
    }
    // Written type arguments can only go when the context spells them too.
    if (qualified.parameterized case final written? when written != namespace) {
      return;
    }
    rule.reportAtNode(node, arguments: [qualified.typeName, qualified.member]);
  }

  bool _reports(MemberKind kind) => switch (kind) {
    .unnamedConstructor => config.unnamedConstructors,
    .namedConstructor => config.namedConstructors,
    .staticMember => config.staticMembers,
    .enumValue => config.enumValues,
  };
}

/// The kinds of member a dot shorthand can reach.
enum MemberKind() {
  unnamedConstructor,
  namedConstructor,
  staticMember,
  enumValue,
}

/// A member reached through its type's name, `Alignment.center`,
/// `int.parse(s)` or `Key(path, c)`, and what makes it a dot shorthand: the
/// [typeRange] replaced by the [replacement]. [parameterized] is the written
/// type when it carries type arguments, `List<int>` in
/// `List<int>.filled(1, 0)`.
class const QualifiedMember({
  required final MemberKind kind,
  required final InterfaceElement type,
  required final String typeName,
  required final String member,
  required final SourceRange typeRange,
  required final String replacement,
  required final InterfaceType? parameterized,
});

/// [node] as a [QualifiedMember], or `null` when it is not a static member
/// access, an enum value, a static method call or a constructor call spelled
/// with its type name.
QualifiedMember? qualifiedMemberOf(Expression node) => switch (node) {
  PrefixedIdentifier(
    prefix: Identifier(:final InterfaceElement element) &&
        final Identifier typeNode,
    identifier: SimpleIdentifier(:final name) && final member,
  ) ||
  PropertyAccess(
    target: Identifier(:final InterfaceElement element) &&
        final Identifier typeNode,
    propertyName: SimpleIdentifier(:final name) && final member,
  ) ||
  MethodInvocation(
    target: Identifier(:final InterfaceElement element) &&
        final Identifier typeNode,
    methodName: SimpleIdentifier(:final name) && final member,
  ) => .new(
    kind: _isEnumValue(member.element) ? .enumValue : .staticMember,
    type: element,
    typeName: typeNode.toSource(),
    member: name,
    typeRange: range.node(typeNode),
    replacement: '',
    parameterized: null,
  ),
  InstanceCreationExpression(
    constructorName: ConstructorName(
      type: NamedType(:final InterfaceElement element) && final namedType,
      :final name,
    ),
  ) =>
    .new(
      kind: name == null ? .unnamedConstructor : .namedConstructor,
      type: element,
      typeName: namedType.toSource(),
      member: name?.name ?? 'new',
      typeRange: range.node(namedType),
      replacement: name == null ? '.new' : '',
      parameterized: switch (namedType) {
        NamedType(typeArguments: null) => null,
        NamedType(:final InterfaceType type) => type,
        _ => null,
      },
    ),
  _ => null,
};

bool _isEnumValue(Element? element) => switch (element) {
  GetterElement(variable: FieldElement(isEnumConstant: true)) => true,
  _ => false,
};

/// The type a dot shorthand in a context of type [type] resolves against:
/// the type itself, its non-nullable form, or what its `FutureOr` wraps.
InterfaceType? namespaceOf(DartType type, TypeSystem typeSystem) {
  var namespace = typeSystem.promoteToNonNull(type);
  while (namespace.isDartAsyncFutureOr) {
    namespace = typeSystem.promoteToNonNull(
      (namespace as InterfaceType).typeArguments.single,
    );
  }
  return switch (namespace) {
    final InterfaceType interface => interface,
    _ => null,
  };
}

/// The type the context imposes on [node], as far as a dot shorthand needs
/// it: `null` when nothing does. The analyzer computes context types while
/// resolving and keeps none of them, so this walks the parents instead. An
/// annotation's arguments get `null` too: tools read annotations with
/// parsers of their own (`package:test` evaluates `@Timeout` itself), and
/// those may not know the shorthand.
DartType? contextTypeOf(Expression node) {
  final parent = node.parent;
  return switch (parent) {
    ArgumentList(parent: Annotation()) => null,
    ArgumentList(parent: final Expression invocation) => _parameterType(
      node.correspondingParameter,
      invocation,
    ),
    NamedArgument(
      :final argumentExpression,
      parent: ArgumentList(parent: final Expression invocation),
    )
        when argumentExpression == node =>
      _parameterType(parent.correspondingParameter, invocation),
    VariableDeclaration(
      :final initializer,
      parent: final VariableDeclarationList list,
    )
        when initializer == node =>
      list.type?.type,
    ReturnStatement(:final expression) when expression == node =>
      _returnedTypeOf(parent.thisOrAncestorOfType<FunctionBody>()),
    ExpressionFunctionBody(:final expression) when expression == node =>
      _returnedTypeOf(parent),
    AssignmentExpression(:final rightHandSide, :final operator)
        when rightHandSide == node &&
            (operator.type == TokenType.EQ ||
                operator.type == TokenType.QUESTION_QUESTION_EQ) =>
      parent.writeType,
    BinaryExpression(:final rightOperand, :final operator)
        when rightOperand == node &&
            (operator.type == TokenType.EQ_EQ ||
                operator.type == TokenType.BANG_EQ) =>
      parent.leftOperand.staticType,
    BinaryExpression(:final rightOperand, :final operator)
        when rightOperand == node &&
            operator.type == TokenType.QUESTION_QUESTION =>
      contextTypeOf(parent),
    ParenthesizedExpression() => contextTypeOf(parent),
    ConditionalExpression(:final thenExpression, :final elseExpression)
        when thenExpression == node || elseExpression == node =>
      contextTypeOf(parent),
    SwitchExpressionCase(
      :final expression,
      parent: final SwitchExpression switch_,
    )
        when expression == node =>
      contextTypeOf(switch_),
    FormalParameterDefaultClause(
      :final value,
      parent: final FormalParameter parameter,
    )
        when value == node =>
      parameter.declaredFragment?.element.type,
    ConstantPattern(:final expression) when expression == node =>
      parent.matchedValueType,
    ListLiteral() => _elementTypeOf(parent, 0),
    SetOrMapLiteral(isSet: true) && final set => _elementTypeOf(set, 0),
    MapLiteralEntry(:final key, :final value, parent: final SetOrMapLiteral map)
        when key == node || value == node =>
      _elementTypeOf(map, key == node ? 0 : 1),
    IfElement(:final thenElement, :final elseElement)
        when thenElement == node || elseElement == node =>
      _collectionContextOf(parent),
    ForElement(:final body) when body == node => _collectionContextOf(parent),
    _ => null,
  };
}

/// What [parameter]'s declaration says once substituted. Type parameters the
/// declaration mentions have to be pinned by something other than the
/// argument: the receiver's type, for an instance member's class parameters
/// (`styles.add(.plain)` on a `List<Style>`), or else the context of the
/// [invocation], which then needs a context type equal to its own type and a
/// declared return type mentioning each of them (`T same<T>(T value)` called
/// as `Style f() => same(.plain)`).
DartType? _parameterType(
  FormalParameterElement? parameter,
  Expression invocation,
) {
  final function = parameter?.baseElement.enclosingElement;
  if (parameter == null || function is! ExecutableElement) {
    return null;
  }
  final mentioned = _typeParametersIn(parameter.baseElement.type);
  final byReceiver = switch (function) {
    ConstructorElement() => const <TypeParameterElement>{},
    ExecutableElement(isStatic: true) => const <TypeParameterElement>{},
    ExecutableElement(
      enclosingElement: InstanceElement(:final typeParameters),
    ) =>
      typeParameters.toSet(),
    _ => const <TypeParameterElement>{},
  };
  final byContext = mentioned.difference(byReceiver);
  if (byContext.isEmpty) {
    return parameter.type;
  }
  final context = contextTypeOf(invocation);
  if (context == null || _nonNull(context) != invocation.staticType) {
    return null;
  }
  final pinned = _typeParametersIn(function.baseElement.returnType)
      .containsAll(byContext);
  return pinned ? parameter.type : null;
}

/// The type parameters [type] mentions.
Set<TypeParameterElement> _typeParametersIn(DartType type) => switch (type) {
  TypeParameterType(:final element) => {element},
  InterfaceType(:final typeArguments) => {
    for (final argument in typeArguments) ..._typeParametersIn(argument),
  },
  FunctionType(:final returnType, :final formalParameters) => {
    ..._typeParametersIn(returnType),
    for (final parameter in formalParameters)
      ..._typeParametersIn(parameter.type),
  },
  RecordType(:final positionalFields, :final namedFields) => {
    for (final field in positionalFields) ..._typeParametersIn(field.type),
    for (final field in namedFields) ..._typeParametersIn(field.type),
  },
  _ => const {},
};

/// The type a `return` in [body] has to produce, from the declared return
/// type of the function the body belongs to; `null` for a lambda, whose
/// return type is only inferred, and for a generator.
DartType? _returnedTypeOf(FunctionBody? body) {
  if (body == null || body.isGenerator) {
    return null;
  }
  final declared = switch (body.parent) {
    MethodDeclaration(:final returnType) => returnType?.type,
    FunctionExpression(parent: FunctionDeclaration(:final returnType)) =>
      returnType?.type,
    _ => null,
  };
  if (declared == null) {
    return null;
  }
  return body.isAsynchronous ? _futureArgument(declared) : declared;
}

/// `T` for a `Future<T>` or `FutureOr<T>` [type], which an `async` body
/// returns a `T` into; `null` otherwise.
DartType? _futureArgument(DartType type) => switch (type) {
  InterfaceType(:final typeArguments)
      when type.isDartAsyncFuture || type.isDartAsyncFutureOr =>
    typeArguments.single,
  _ => null,
};

/// The context type of the elements of [element], a collection element
/// standing in for its parent literal's elements.
DartType? _collectionContextOf(CollectionElement element) =>
    switch (element.parent) {
      final ListLiteral list => _elementTypeOf(list, 0),
      SetOrMapLiteral(isSet: true) && final set => _elementTypeOf(set, 0),
      final IfElement outer => _collectionContextOf(outer),
      final ForElement outer => _collectionContextOf(outer),
      _ => null,
    };

/// Type argument [index] of [literal]'s type, when its own type arguments or
/// its context fix it rather than its elements: `[Style.plain]` alone infers
/// `List<Style>` from the element, which a shorthand could no longer do.
DartType? _elementTypeOf(TypedLiteral literal, int index) {
  if (literal.typeArguments case final arguments?) {
    return arguments.arguments.elementAtOrNull(index)?.type;
  }
  final context = contextTypeOf(literal);
  if (context == null) {
    return null;
  }
  final literalType = literal.staticType;
  final contextType = _nonNull(context);
  if (literalType is InterfaceType &&
      contextType is InterfaceType &&
      contextType.element == literalType.element) {
    return contextType.typeArguments.elementAtOrNull(index);
  }
  return null;
}

DartType _nonNull(DartType type) => switch (type) {
  InterfaceType(nullabilitySuffix: NullabilitySuffix.question) =>
    type.element.instantiate(
      typeArguments: type.typeArguments,
      nullabilitySuffix: NullabilitySuffix.none,
    ),
  _ => type,
};

/// Rewrites the flagged expression into its dot shorthand.
class ReplaceWithDotShorthand({required super.context})
    extends ResolvedCorrectionProducer {
  static const kind = FixKind(
    'leancode_lint.fix.replaceWithDotShorthand',
    DartFixKindPriority.standard,
    'Replace with a dot shorthand',
  );

  @override
  CorrectionApplicability get applicability => .automatically;

  @override
  FixKind get fixKind => kind;

  @override
  Future<void> compute(ChangeBuilder builder) async {
    final qualified = qualifiedMemberOf(node as Expression)!;
    await builder.addDartFileEdit(
      file,
      (builder) => builder.addSimpleReplacement(
        qualified.typeRange,
        qualified.replacement,
      ),
    );
  }
}
