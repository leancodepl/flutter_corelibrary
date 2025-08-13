import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/token.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/nullability_suffix.dart';
import 'package:analyzer/error/error.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';
import 'package:leancode_lint/common_type_checkers.dart';
import 'package:leancode_lint/utils.dart';

String typeParametersString(
  Iterable<TypeParameter> typeParameters, {
  bool withBounds = false,
}) {
  final parameters = typeParameters
      .map((e) => withBounds ? e.toSource() : e.name)
      .join(', ');

  if (parameters.isNotEmpty) {
    return '<$parameters>';
  } else {
    return '';
  }
}

Expression? maybeGetSingleReturnExpression(FunctionBody body) {
  return switch (body) {
    ExpressionFunctionBody(:final expression) ||
    BlockFunctionBody(
      block: Block(statements: [ReturnStatement(:final expression?)]),
    ) => expression,
    _ => null,
  };
}

class _HookExpressionsGatherer extends GeneralizingAstVisitor<void> {
  final List<InvocationExpression> _hookExpressions = [];

  static List<InvocationExpression> gather(AstNode node) {
    final visitor = _HookExpressionsGatherer();
    node.accept(visitor);
    return visitor._hookExpressions;
  }

  // use + upper case letter to avoid cases like "user"
  static final _isHookRegex = RegExp('^_?use[0-9A-Z]');

  @override
  void visitInstanceCreationExpression(InstanceCreationExpression node) {
    switch (maybeHookBuilderBody(node)) {
      case null:
        // It is not a hook builder, let's continue searching
        return super.visitInstanceCreationExpression(node);
      case final _:
        // this is a hook builder, so it has a new hook context for used hooks: stop recursing
        return;
    }
  }

  @override
  void visitInvocationExpression(InvocationExpression node) {
    if (_isHookRegex.hasMatch(node.beginToken.lexeme)) {
      _hookExpressions.add(node);
    }

    super.visitInvocationExpression(node);
  }
}

List<InvocationExpression> getAllInnerHookExpressions(AstNode node) {
  return _HookExpressionsGatherer.gather(node);
}

/// Given an instance creation, returns the builder function body if the node is a HookBuilder.
FunctionBody? maybeHookBuilderBody(InstanceCreationExpression node) {
  final classElement = node.constructorName.type.element;
  if (classElement == null) {
    return null;
  }

  final isHookBuilder = const TypeChecker.any([
    TypeCheckers.hookBuilder,
    TypeCheckers.hookConsumer,
  ]).isExactly(classElement);
  if (!isHookBuilder) {
    return null;
  }

  final builderParameter = node.argumentList.arguments
      .whereType<NamedExpression>()
      .firstWhereOrNull((e) => e.name.label.name == 'builder');
  if (builderParameter case NamedExpression(
    expression: FunctionExpression(:final body),
  )) {
    return body;
  }

  return null;
}

class _ReturnExpressionGatherer extends GeneralizingAstVisitor<void> {
  final List<Expression?> _returnExpressions = [];

  static List<Expression?> gather(AstNode node) {
    final visitor = _ReturnExpressionGatherer();
    node.visitChildren(visitor);
    return visitor._returnExpressions;
  }

  @override
  void visitFunctionBody(FunctionBody node) {
    // stop recursing on a new function body, return statements will be from a different scope
  }

  @override
  void visitReturnStatement(ReturnStatement node) {
    _returnExpressions.add(node.expression);
  }
}

/// Returns all return expressions of a function body.
List<Expression?> getAllReturnExpressions(FunctionBody body) {
  return switch (body) {
    BlockFunctionBody(:final block) => _ReturnExpressionGatherer.gather(block),
    ExpressionFunctionBody(:final expression) => [expression],
    EmptyFunctionBody() || NativeFunctionBody() => const [],
  };
}

bool isWidgetClass(ClassDeclaration node) => switch (node.declaredElement) {
  final element? => const TypeChecker.any([
    TypeCheckers.statelessWidget,
    TypeCheckers.state,
    TypeCheckers.hookWidget,
  ]).isSuperOf(element),
  _ => false,
};

MethodDeclaration? getBuildMethod(ClassDeclaration node) => node.members
    .whereType<MethodDeclaration>()
    .firstWhereOrNull((member) => member.name.lexeme == 'build');

extension LintRuleNodeRegistryExtensions on LintRuleNodeRegistry {
  void addRegularComment(void Function(Token comment) listener) {
    addCompilationUnit((node) {
      bool isRegularComment(Token commentToken) {
        final token = commentToken.toString();

        return !token.startsWith('///') && token.startsWith('//');
      }

      Token? token = node.root.beginToken;
      while (token != null) {
        Token? commentToken = token.precedingComments;
        while (commentToken != null) {
          if (isRegularComment(commentToken)) {
            listener(commentToken);
          }
          commentToken = commentToken.next;
        }

        if (token == token.next) {
          break;
        }

        token = token.next;
      }
    });
  }

  void addHookWidgetBody(
    void Function(FunctionBody node, AstNode diagnosticNode) listener, {
    bool isExactly = false,
  }) {
    addInstanceCreationExpression((node) {
      if (maybeHookBuilderBody(node) case final body?) {
        listener(body, node.constructorName);
      }
    });
    addClassDeclaration((node) {
      final element = node.declaredElement;
      if (element == null) {
        return;
      }

      const checker = TypeChecker.any([
        TypeCheckers.hookWidget,
        TypeCheckers.hookConsumerWidget,
      ]);

      final AstNode diagnosticNode;
      if (isExactly) {
        final superclass = node.extendsClause?.superclass;
        final superclassElement = superclass?.element;
        if (superclass == null || superclassElement == null) {
          return;
        }

        final isDirectHookWidget = checker.isExactly(superclassElement);
        if (!isDirectHookWidget) {
          return;
        }
        diagnosticNode = superclass;
      } else {
        final isHookWidget = checker.isSuperOf(element);
        if (!isHookWidget) {
          return;
        }
        diagnosticNode = node;
      }

      final buildMethod = getBuildMethod(node);
      if (buildMethod == null) {
        return;
      }

      listener(buildMethod.body, diagnosticNode);
    });
  }

  void addBloc(void Function(ClassDeclaration node, _BlocData data) listener) {
    addClassDeclaration((node) {
      if (_maybeBlocData(node) case final data?) {
        listener(node, data);
      }
    });
  }
}

typedef _BlocData = ({
  String baseName,
  InterfaceElement blocElement,
  InterfaceElement stateElement,
  InterfaceElement? eventElement,
  InterfaceElement? presentationEventElement,
});

_BlocData? _maybeBlocData(ClassDeclaration clazz) {
  final blocElement = clazz.declaredElement;

  if (blocElement == null ||
      !TypeCheckers.blocBase.isAssignableFrom(blocElement)) {
    return null;
  }

  final baseName = clazz.name.lexeme.replaceAll(RegExp(r'(Cubit|Bloc)$'), '');

  final stateType = blocElement.allSupertypes
      .firstWhere(TypeCheckers.blocBase.isExactlyType)
      .typeArguments
      .singleOrNull;
  if (stateType == null) {
    return null;
  }

  final stateElement = stateType.element;
  if (stateElement is! InterfaceElement) {
    return null;
  }

  final eventElement = blocElement.allSupertypes
      .firstWhereOrNull(TypeCheckers.bloc.isExactlyType)
      ?.typeArguments
      .firstOrNull
      ?.element;
  if (eventElement is! InterfaceElement?) {
    return null;
  }

  final presentationEventElement = blocElement.mixins
      .firstWhereOrNull(TypeCheckers.blocPresentation.isExactlyType)
      ?.typeArguments
      .elementAtOrNull(1)
      ?.element;
  if (presentationEventElement is! InterfaceElement?) {
    return null;
  }

  return (
    baseName: baseName,
    blocElement: blocElement,
    stateElement: stateElement,
    eventElement: eventElement,
    presentationEventElement: presentationEventElement,
  );
}

bool inSameFile(Element element1, Element element2) {
  final file1 = element1.source?.uri;
  final file2 = element2.source?.uri;

  return file1 != null && file2 != null && file1 == file2;
}

extension TypeSubclasses on InterfaceElement {
  Iterable<ClassElement> get subclasses {
    final typeChecker = TypeChecker.fromStatic(thisType);
    return library.units
        .expand((u) => u.classes)
        .where(
          (clazz) =>
              typeChecker.isAssignableFrom(clazz) &&
              !typeChecker.isExactly(clazz),
        );
  }
}

bool isExpressionExactlyType(
  Expression expression,
  String typeName,
  String packageName,
) {
  if (expression.staticType case final type?) {
    return TypeChecker.fromName(
      typeName,
      packageName: packageName,
    ).isExactlyType(type);
  }
  return false;
}

/// Checks whether an instance creation uses only the specified named parameter.
///
/// Returns true when the [node] has:
/// - Only one relevant named argument whose name equals [parameter]
/// - The argument value is not a null literal and the argument type is not
///   nullable (i.e. not `T?`)
/// - No other arguments are present, except those explicitly listed in
///   [ignoredParameters]
///
/// Otherwise returns false.
bool isInstanceCreationExpressionOnlyUsingParameter(
  InstanceCreationExpression node, {
  required String parameter,
  Set<String> ignoredParameters = const {},
}) {
  var hasParameter = false;

  for (final argument in node.argumentList.arguments) {
    if (argument case NamedExpression(
      name: Label(label: SimpleIdentifier(name: final argumentName)),
      :final expression,
      :final staticType,
    )) {
      if (ignoredParameters.contains(argumentName)) {
        continue;
      } else if (argumentName == parameter &&
          expression is! NullLiteral &&
          staticType?.nullabilitySuffix != NullabilitySuffix.question) {
        hasParameter = true;
      } else {
        // Other named arguments are not allowed
        return false;
      }
    } else {
      // Other arguments are not allowed
      return false;
    }
  }
  return hasParameter;
}

/// A fix that replaces the widget constructor name with a new one specified as [widgetName].
///
/// Assumption: the corresponding lint diagnostic reports an error whose
/// source range matches the constructor's name (identifier). The fix applies
/// the replacement to that exact range.
///
/// Example:
/// ```dart
/// Container(alignment: null, child: const SizedBox());
/// ```
///
/// will be replaced with:
/// ```dart
/// Align(alignment: null, child: const SizedBox());
/// ```
class ChangeWidgetNameFix extends DartFix {
  ChangeWidgetNameFix(this.widgetName);

  final String widgetName;

  @override
  void run(
    CustomLintResolver resolver,
    ChangeReporter reporter,
    CustomLintContext context,
    AnalysisError analysisError,
    List<AnalysisError> errors,
  ) {
    reporter
        .createChangeBuilder(message: 'Replace with $widgetName', priority: 1)
        .addDartFileEdit(
          (builder) => builder.addSimpleReplacement(
            analysisError.sourceRange,
            widgetName,
          ),
        );
  }
}
