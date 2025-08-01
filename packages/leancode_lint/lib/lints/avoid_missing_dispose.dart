// Replace this once analyzer is updated
// ignore_for_file: deprecated_member_use

import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/dart/element/element2.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:analyzer/error/error.dart' hide LintCode;
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';
import 'package:leancode_lint/utils.dart';
import 'package:yaml/yaml.dart';

class _IgnoredInstance {
  const _IgnoredInstance({required this.name, required this.packageName});

  final String name;
  final String packageName;
}

class AvoidMissingDisposeConfig {
  const AvoidMissingDisposeConfig({
    this.ignoredInstances = const {},
    this.ignoredInstancesCheckers = const [],
  });

  factory AvoidMissingDisposeConfig.fromConfig(Map<String, Object?> json) {
    final ignoredInstances =
        (json['ignored_instances'] as YamlList?)?.nodes
            .map(
              (e) => _IgnoredInstance(
                name: (e as YamlMap)['ignore'] as String,
                packageName: e['from_package'] as String,
              ),
            )
            .toSet() ??
        const {};
    return AvoidMissingDisposeConfig(
      ignoredInstances: ignoredInstances,
      ignoredInstancesCheckers: [
        for (final _IgnoredInstance(:name, :packageName) in ignoredInstances)
          if (packageName.startsWith('dart:'))
            TypeChecker.fromUrl('$packageName#$name')
          else
            TypeChecker.fromName(name, packageName: packageName),
      ],
    );
  }

  final Set<_IgnoredInstance> ignoredInstances;
  final List<TypeChecker> ignoredInstancesCheckers;
}

/// Checks for proper disposal of resources in StatefulWidget classes.
/// Warns when disposable resources are not properly disposed in the dispose() method.
class AvoidMissingDispose extends DartLintRule {
  const AvoidMissingDispose({required this.config})
    : super(
        code: const LintCode(
          name: ruleName,
          problemMessage:
              'Resource should be disposed in the dispose() method.',
          correctionMessage: 'Add disposal of this resource.',
          errorSeverity: ErrorSeverity.WARNING,
        ),
      );

  factory AvoidMissingDispose.fromConfigs(CustomLintConfigs configs) {
    final config = AvoidMissingDisposeConfig.fromConfig(
      configs.rules[ruleName]?.json ?? {},
    );

    return AvoidMissingDispose(config: config);
  }

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

      if (type == null || _isIgnoredInstance(type)) {
        return;
      }

      final classNode = _getContainingClass(node);
      if (classNode == null) {
        return;
      }

      if (_isWidgetClass(classNode) &&
          !_isFieldUsedByConstructor(classNode, node)) {
        reporter.atNode(node, code);
        return;
      }

      if (!_isStateOfWidget(classNode) || !_isDisposable(type)) {
        return;
      }

      final disposeExpressions = _DisposeExpressionsGatherer.gatherForTarget(
        node: classNode,
        targetName: node.fields.variables.first.name.lexeme,
      );

      if (disposeExpressions.isEmpty) {
        reporter.atNode(
          node,
          code,
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

      if (type == null || _isIgnoredInstance(type)) {
        return;
      }

      final classNode = _getContainingClass(node);

      if (classNode == null ||
          !(_isWidgetClass(classNode) || _isStateOfWidget(classNode)) ||
          !_isDisposable(type)) {
        return;
      }

      if (_isInReturnWidget(node)) {
        reporter.atNode(node, code);
        return;
      }
    });
  }

  bool _isIgnoredInstance(InterfaceType type) {
    return config.ignoredInstancesCheckers.any(
      (checker) => checker.isExactly(type.element),
    );
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
    if (constructorDeclaration.parameters.parameters.any(
      (parameter) => parameter.name?.lexeme == parameterName,
    )) {
      return true;
    }

    return constructorDeclaration.initializers
        .whereType<ConstructorFieldInitializer>()
        .any((initializer) => initializer.fieldName.name == parameterName);
  }

  ConstructorDeclaration? _getConstructorDeclaration(
    ClassDeclaration classNode,
  ) {
    return classNode.members.firstWhereOrNull(
          (member) => switch (member) {
            final ConstructorDeclaration _ => true,
            _ => false,
          },
        )
        as ConstructorDeclaration?;
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
    return type.methods2.any((method) => method.name3 == 'dispose') ||
        type.element3.inheritedMembers.entries.any(
          (entry) =>
              entry.key.name == 'dispose' &&
              entry.value.baseElement is MethodElement2,
        );
  }

  bool _isWidgetType(InterfaceType type) {
    const widgetTypeChecker = TypeChecker.fromName(
      'Widget',
      packageName: 'flutter',
    );

    return widgetTypeChecker.isExactlyType(type) ||
        widgetTypeChecker.isSuperTypeOf(type);
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
      if (currentNode case MethodDeclaration(
        returnType: NamedType(type: final InterfaceType type),
      ) when _isWidgetType(type)) {
        returnsWidget = true;
      }

      currentNode = currentNode.parent;
    }
    return returnsWidget && isInReturn;
  }

  bool _isStateOfWidget(ClassDeclaration classNode) {
    const stateTypeChecker = TypeChecker.fromName(
      'State',
      packageName: 'flutter',
    );
    return switch (classNode.declaredElement) {
      final element? =>
        stateTypeChecker.isExactly(element) ||
            stateTypeChecker.isSuperOf(element),
      _ => false,
    };
  }

  bool _isWidgetClass(ClassDeclaration classNode) {
    const widgetTypeChecker = TypeChecker.fromName(
      'Widget',
      packageName: 'flutter',
    );

    return widgetTypeChecker.isExactly(classNode.declaredElement!) ||
        widgetTypeChecker.isSuperOf(classNode.declaredElement!);
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
    if (node.expression
        case MethodInvocation(
              methodName: SimpleIdentifier(name: disposeMethodName),
              target: SimpleIdentifier(:final name),
            ) &&
            final invocation when name == targetName) {
      _disposeExpressions.add(invocation);
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
    if (analysisError.data case _AvoidMissingDisposeAnalysisData(
      classNode: final classNode,
      instanceName: final instanceName,
    )) {
      final disposeMethodNode = _getStateDisposeMethod(classNode);
      if (disposeMethodNode?.body case BlockFunctionBody(
        block: Block(statements: [final statement, ...]),
      )) {
        reporter
            .createChangeBuilder(
              message:
                  'Add $instanceName.dispose() to the state dispose method',
              priority: 80,
            )
            .addDartFileEdit((builder) {
              builder.addSimpleInsertion(
                statement.offset,
                '$instanceName.dispose();\n    ',
              );
            });
      }
    }
  }

  MethodDeclaration? _getStateDisposeMethod(ClassDeclaration classNode) {
    return classNode.members.whereType<MethodDeclaration>().firstWhereOrNull(
      (member) => member.name.lexeme == 'dispose',
    );
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
