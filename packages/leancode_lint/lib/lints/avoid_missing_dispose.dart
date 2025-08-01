import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/element2.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:analyzer/error/error.dart' hide LintCode;
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';
import 'package:leancode_lint/utils.dart';
import 'package:yaml/yaml.dart';

class AvoidMissingDisposeConfig {
  const AvoidMissingDisposeConfig({this.ignoredInstances = const {}});

  factory AvoidMissingDisposeConfig.fromConfig(Map<String, Object?> json) {
    return AvoidMissingDisposeConfig(
      ignoredInstances:
          (json['ignored_instances'] as YamlList?)
              ?.map((e) => e.toString())
              .toSet() ??
          {},
    );
  }

  final Set<String> ignoredInstances;
}

/// Checks for proper disposal of resources in StatefulWidget classes.
/// Warns when disposable resources are not properly disposed in the dispose() method.
class AvoidMissingDispose extends DartLintRule {
  AvoidMissingDispose({required this.config}) : super(code: _createCode());

  AvoidMissingDispose.fromConfigs(CustomLintConfigs configs)
    : this(
        config: AvoidMissingDisposeConfig.fromConfig(
          configs.rules[ruleName]?.json ?? {},
        ),
      );

  static LintCode _createCode() => const LintCode(
    name: ruleName,
    problemMessage: 'Resource should be disposed in the dispose() method.',
    correctionMessage: 'Add disposal of this resource.',
    errorSeverity: ErrorSeverity.WARNING,
  );

  final AvoidMissingDisposeConfig config;

  static const ruleName = 'avoid_missing_dispose';

  @override
  List<Fix> getFixes() => [_AddDisposeMethod()];

  @override
  void run(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
  ) {
    context.registry.addFieldDeclaration((node) {
      final type = _getFieldDeclarationType(node);

      if (type == null ||
          config.ignoredInstances.contains(type.element3.name3)) {
        return;
      }

      final classNode = _getContainingClass(node);
      if (classNode == null) {
        return;
      }

      if (_isWidget(classNode) && !_isFieldUsedByConstructor(classNode, node)) {
        reporter.atNode(node, _createCode());
        return;
      }

      if (!_isStateOfWidget(classNode)) {
        return;
      }

      if (!_isDisposable(type)) {
        return;
      }

      final disposeExpressions = _DisposeExpressionsGatherer.gatherForTarget(
        node: classNode,
        targetName: node.fields.variables.first.name.lexeme,
      );

      if (disposeExpressions.isEmpty) {
        reporter.atNode(
          node,
          _createCode(),
          data: _AvoidMissingDisposeAnalysisData(
            instanceName: node.fields.variables.first.name.lexeme,
            classNode: classNode,
          ),
        );
      }
    });
    context.registry.addInstanceCreationExpression((node) {
      final type = switch (node.staticType) {
        final InterfaceType type => type,
        _ => null,
      };

      if (type == null ||
          config.ignoredInstances.contains(type.element3.name3)) {
        return;
      }

      final classNode = _getContainingClass(node);

      if (classNode == null ||
          !(_isWidget(classNode) || _isStateOfWidget(classNode))) {
        return;
      }

      if (!_isDisposable(type)) {
        return;
      }

      if (_isInReturnWidget(node)) {
        reporter.atNode(node, _createCode());
        return;
      }
    });
  }

  InterfaceType? _getFieldDeclarationType(FieldDeclaration field) {
    if (field.fields.type?.type case final InterfaceType type) {
      return type;
    }
    if (field.fields.variables.first.initializer?.staticType
        case final InterfaceType? type) {
      return type;
    }
    return null;
  }

  bool _isFieldUsedByConstructor(
    ClassDeclaration classNode,
    FieldDeclaration node,
  ) {
    final constructorDeclaration = _getConstructorDeclaration(classNode);
    if (constructorDeclaration == null) {
      return false;
    }

    return _hasConstructorParameterOrInitializer(
      constructorDeclaration,
      node.fields.variables.first.name.lexeme,
    );
  }

  bool _hasConstructorParameterOrInitializer(
    ConstructorDeclaration constructorDeclaration,
    String parameterName,
  ) {
    for (final parameter in constructorDeclaration.parameters.parameters) {
      if (parameter.name?.lexeme == parameterName) {
        return true;
      }
    }
    for (final initializer in constructorDeclaration.initializers) {
      if (initializer case final ConstructorFieldInitializer initializer) {
        if (initializer.fieldName.name == parameterName) {
          return true;
        }
      }
    }
    return false;
  }

  ConstructorDeclaration? _getConstructorDeclaration(
    ClassDeclaration classNode,
  ) {
    for (final member in classNode.members) {
      if (member case final ConstructorDeclaration constructorDeclaration) {
        return constructorDeclaration;
      }
    }
    return null;
  }

  ClassDeclaration? _getContainingClass(AstNode node) {
    var classNode = node.parent;
    while (classNode != null && classNode is! ClassDeclaration) {
      classNode = classNode.parent;
    }
    if (classNode case final ClassDeclaration classNode) {
      return classNode;
    }
    return null;
  }

  bool _isDisposable(InterfaceType type) {
    // Checks if current class has dispose method
    var hasDispose = type.methods2.any((method) => method.name3 == 'dispose');
    // Checks if current class has dispose method in the inherited members
    if (!hasDispose) {
      hasDispose =
          type.element3.inheritedMembers.entries.firstWhereOrNull(
            (entry) =>
                entry.key.name == 'dispose' &&
                entry.value.baseElement is MethodElement2,
          ) !=
          null;
    }
    return hasDispose;
  }

  bool _isType(InterfaceType type, String typeName) {
    if (type.element3.name3 == typeName) {
      return true;
    }
    return type.element3.allSupertypes.any(
      (supertype) => supertype.element3.name3 == typeName,
    );
  }

  bool _isInReturnWidget(InstanceCreationExpression node) {
    AstNode? currentNode = node;
    var returnsWidget = false;
    var isInReturn = false;
    while (currentNode != null && !(returnsWidget && isInReturn)) {
      if (!isInReturn &&
          (currentNode is ReturnStatement ||
              currentNode is ExpressionFunctionBody)) {
        isInReturn = true;
      }
      if (currentNode is MethodDeclaration) {
        if (currentNode.returnType case final NamedType returnType
            when returnType.type is InterfaceType &&
                _isType(returnType.type! as InterfaceType, 'Widget')) {
          returnsWidget = true;
        } else {
          return false;
        }
      }
      currentNode = currentNode.parent;
    }
    return returnsWidget && isInReturn;
  }

  bool _isStateOfWidget(ClassDeclaration classNode) {
    // Suggested ClassElement2 doesn't work in this case
    // ignore: deprecated_member_use
    if (classNode.declaredFragment case final ClassElement element) {
      return element.allSupertypes.any(
        (type) => type.element3.name3 == 'State',
      );
    }
    return false;
  }

  bool _isWidget(ClassDeclaration classNode) {
    // Suggested ClassElement2 doesn't work in this case
    // ignore: deprecated_member_use
    if (classNode.declaredFragment case final ClassElement element) {
      return element.allSupertypes.any(
        (type) => type.element3.name3 == 'Widget',
      );
    }
    return false;
  }
}

class _DisposeExpressionsGatherer extends GeneralizingAstVisitor<void> {
  _DisposeExpressionsGatherer({required this.targetName});
  final String targetName;

  final List<InvocationExpression> _disposeExpressions = [];

  static List<InvocationExpression> gatherForTarget({
    required AstNode node,
    required String targetName,
  }) {
    final visitor = _DisposeExpressionsGatherer(targetName: targetName);
    node.accept(visitor);
    return visitor._disposeExpressions;
  }

  static const disposeMethodName = 'dispose';

  @override
  void visitExpressionStatement(ExpressionStatement node) {
    if (node.expression case final MethodInvocation methodInvocation) {
      if (methodInvocation.methodName.name == disposeMethodName) {
        if (methodInvocation.target case final SimpleIdentifier target) {
          if (target.name == targetName) {
            _disposeExpressions.add(methodInvocation);
          }
        }
      }
    }
  }
}

class _AddDisposeMethod extends DartFix {
  @override
  void run(
    CustomLintResolver resolver,
    ChangeReporter reporter,
    CustomLintContext context,
    AnalysisError analysisError,
    List<AnalysisError> others,
  ) {
    if (analysisError.data case final _AvoidMissingDisposeAnalysisData data) {
      final disposeMethodNode = _getStateDisposeMethod(data.classNode);
      if (disposeMethodNode?.body case final BlockFunctionBody body
          when body.block.statements.isNotEmpty) {
        reporter
            .createChangeBuilder(
              message:
                  'Add ${data.instanceName}.dispose() to the state dispose method',
              priority: 80,
            )
            .addDartFileEdit((builder) {
              builder.addSimpleInsertion(
                body.block.statements.first.offset,
                '${data.instanceName}.dispose();\n    ',
              );
            });
      }
    }
  }

  MethodDeclaration? _getStateDisposeMethod(ClassDeclaration classNode) {
    for (final member in classNode.members) {
      if (member case final MethodDeclaration methodDeclaration) {
        if (methodDeclaration.name.lexeme == 'dispose') {
          return methodDeclaration;
        }
      }
    }
    return null;
  }
}

class _AvoidMissingDisposeAnalysisData {
  const _AvoidMissingDisposeAnalysisData({
    required this.instanceName,
    required this.classNode,
  });

  final String instanceName;
  final ClassDeclaration classNode;
}
