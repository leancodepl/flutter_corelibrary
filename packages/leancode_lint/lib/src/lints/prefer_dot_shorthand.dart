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

/// Reports a static member, an enum value, or a constructor that is written
/// with its type name even though the context type is the same type, so a
/// dot shorthand could be used instead. For example, `Alignment.center`
/// passed to a parameter of type `Alignment` is reported, and `.center` is
/// suggested.
///
/// The analyzer does not store context types, so the rule determines them
/// from the parent of the expression:
///
/// - an argument, using the parameter's type. If the parameter's type
///   contains type parameters, they must be determined by something other
///   than the argument itself: by the receiver for an instance member
///   (`styles.add(.center)` on a `List<Alignment>`), or by the context type
///   of the invocation.
/// - a variable initializer, a default value, or an assignment
/// - a `return` statement or `=>` body, using the declared return type. In
///   an `async` body, the type argument of `Future<T>` or `FutureOr<T>` is
///   used.
/// - the right operand of `==` or `!=`
/// - a constant pattern, using the matched value type
/// - a branch of `??`, `?:`, or a switch expression, and a parenthesized
///   expression
/// - an element of a list, set, or map literal with explicit type arguments
///   or a context type
///
/// A nullable context type and `FutureOr<T>` are resolved to the underlying
/// type. Explicit type arguments are only removed when they are the same as
/// the context type's. Arguments of annotations are not reported, because
/// some tools parse annotations themselves and do not support dot shorthands
/// (`package:test` evaluates `@Timeout(Duration(minutes: 1))` this way).
///
/// The kinds of members that are reported are configured via
/// `LeanCodeLintConfig.preferDotShorthand`.
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
    // Explicit type arguments can only be removed when they are the same as
    // the context type's.
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

/// The kinds of members that can be written as a dot shorthand.
enum MemberKind() {
  unnamedConstructor,
  namedConstructor,
  staticMember,
  enumValue,
}

/// A member accessed through its type name, such as `Alignment.center`,
/// `int.parse(s)` or `Key(path, c)`. [typeRange] is the range of the type
/// name, which the fix replaces with [replacement]. [parameterized] is the
/// written type when it has explicit type arguments, for example `List<int>`
/// in `List<int>.filled(1, 0)`.
class const QualifiedMember({
  required final MemberKind kind,
  required final InterfaceElement type,
  required final String typeName,
  required final String member,
  required final SourceRange typeRange,
  required final String replacement,
  required final InterfaceType? parameterized,
});

/// Returns [node] as a [QualifiedMember], or `null` if it is not a static
/// member access, an enum value, a static method call, or a constructor call
/// written with its type name.
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

/// Returns the type that a dot shorthand in a context of type [type]
/// resolves against: the type made non-nullable, with `FutureOr` unwrapped.
/// Returns `null` if the result is not an interface type.
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

/// Returns the context type of [node], or `null` if it has none. The
/// analyzer does not store context types, so this walks up the parents of
/// [node]. Arguments of annotations get `null` on purpose: some tools parse
/// annotations themselves and do not support dot shorthands.
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

/// Returns the type of [parameter] in [invocation]. If the declared type of
/// the parameter contains type parameters, they must be determined by
/// something other than the argument: by the receiver, for the class type
/// parameters of an instance member (`styles.add(.plain)` on a
/// `List<Style>`), or by the context type of [invocation], which then has to
/// be equal to the invocation's type and be mentioned by the declared return
/// type (`T same<T>(T value)` called as `Style f() => same(.plain)`).
/// Otherwise returns `null`.
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

/// Returns the type parameters that [type] refers to.
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

/// Returns the type that a `return` in [body] has to produce, based on the
/// declared return type of the enclosing function. Returns `null` for a
/// lambda, whose return type is inferred, and for a generator.
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

/// Returns `T` if [type] is `Future<T>` or `FutureOr<T>`, which is the type
/// an `async` body returns. Otherwise returns `null`.
DartType? _futureArgument(DartType type) => switch (type) {
  InterfaceType(:final typeArguments)
      when type.isDartAsyncFuture || type.isDartAsyncFutureOr =>
    typeArguments.single,
  _ => null,
};

/// Returns the context type of the elements of [element], which is an `if`
/// or `for` element inside a collection literal.
DartType? _collectionContextOf(CollectionElement element) =>
    switch (element.parent) {
      final ListLiteral list => _elementTypeOf(list, 0),
      SetOrMapLiteral(isSet: true) && final set => _elementTypeOf(set, 0),
      final IfElement outer => _collectionContextOf(outer),
      final ForElement outer => _collectionContextOf(outer),
      _ => null,
    };

/// Returns type argument [index] of [literal]'s type if it is determined by
/// the literal's explicit type arguments or by its context type. Otherwise
/// returns `null`: without a context, `[Style.plain]` infers `List<Style>`
/// from its element, which would not be possible with a shorthand.
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

/// Replaces the reported expression with a dot shorthand.
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
