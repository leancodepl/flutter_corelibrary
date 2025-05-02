import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/token.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';
import 'package:leancode_lint/utils.dart';

String typeParametersString(
  Iterable<TypeParameter> typeParameters, {
  bool withBounds = false,
}) {
  final parameters =
      typeParameters.map((e) => withBounds ? e.toSource() : e.name).join(', ');

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
      block: Block(
        statements: [
          ReturnStatement(:final expression?),
        ],
      )
    ) =>
      expression,
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
    TypeChecker.fromName(
      'HookBuilder',
      packageName: 'flutter_hooks',
    ),
    TypeChecker.fromName(
      'HookConsumer',
      packageName: 'hooks_riverpod',
    ),
  ]).isExactly(classElement);
  if (!isHookBuilder) {
    return null;
  }

  final builderParameter = node.argumentList.arguments
      .whereType<NamedExpression>()
      .firstWhereOrNull((e) => e.name.label.name == 'builder');
  if (builderParameter
      case NamedExpression(expression: FunctionExpression(:final body))) {
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
          TypeChecker.fromName('StatelessWidget', packageName: 'flutter'),
          TypeChecker.fromName('State', packageName: 'flutter'),
          TypeChecker.fromName('HookWidget', packageName: 'flutter_hooks'),
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
        TypeChecker.fromName(
          'HookWidget',
          packageName: 'flutter_hooks',
        ),
        TypeChecker.fromName(
          'HookConsumerWidget',
          packageName: 'hooks_riverpod',
        ),
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

const _blocBase = TypeChecker.fromName('BlocBase', packageName: 'bloc');
const _bloc = TypeChecker.fromName('Bloc', packageName: 'bloc');
const _blocPresentation = TypeChecker.fromName(
  'BlocPresentationMixin',
  packageName: 'bloc_presentation',
);

typedef _BlocData = ({
  String baseName,
  ClassElement stateElement,
  ClassElement? eventElement,
  ClassElement? presentationEventElement,
  bool inSamePackage,
});

_BlocData? _maybeBlocData(ClassDeclaration clazz) {
  final classElement = clazz.declaredElement;

  if (classElement == null || !_blocBase.isAssignableFrom(classElement)) {
    return null;
  }

  final baseName = clazz.name.lexeme.replaceAll(RegExp(r'(Cubit|Bloc)$'), '');

  final stateType = classElement.allSupertypes
      .firstWhere((t) => _blocBase.isExactly(t.element))
      .typeArguments
      .singleOrNull;
  if (stateType == null) {
    return null;
  }

  final stateElement = stateType.element;
  if (stateElement is! ClassElement) {
    return null;
  }

  final eventElement = classElement.allSupertypes
      .firstWhereOrNull((t) => _bloc.isExactly(t.element))
      ?.typeArguments
      .firstOrNull
      ?.element;
  if (eventElement is! ClassElement?) {
    return null;
  }

  final presentationEventElement = classElement.mixins
      .firstWhereOrNull((m) => _blocPresentation.isExactly(m.element))
      ?.typeArguments
      .elementAtOrNull(1)
      ?.element;
  if (presentationEventElement is! ClassElement?) {
    return null;
  }

  return (
    baseName: baseName,
    stateElement: stateElement,
    eventElement: eventElement,
    presentationEventElement: presentationEventElement,
    inSamePackage: _inSamePackage(classElement, stateElement) &&
        (eventElement == null || _inSamePackage(classElement, eventElement)),
  );
}

bool _inSamePackage(Element element1, Element element2) {
  final package1 = element1.package;
  final package2 = element2.package;

  return package1 != null && package2 != null && package1 == package2;
}

extension on Element {
  String? get package => switch (library?.definingCompilationUnit.source.uri) {
        final uri? => '${uri.scheme}:${uri.pathSegments.first}',
        null => null,
      };
}

extension ClassSubclasses on ClassElement {
  Iterable<ClassElement> get subclasses {
    final typeChecker = TypeChecker.fromStatic(thisType);
    return library.units.expand((u) => u.classes).where(
          (clazz) =>
              typeChecker.isAssignableFrom(clazz) &&
              !typeChecker.isExactly(clazz),
        );
  }
}
