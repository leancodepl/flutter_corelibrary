import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/error/error.dart';
import 'package:leancode_lint/src/bloc_utils.dart';
import 'package:leancode_lint/src/type_checker.dart';

class BlocClassModifiers extends AnalysisRule {
  BlocClassModifiers()
    : super(name: code.lowerCaseName, description: code.problemMessage);

  static const code = LintCode(
    'bloc_class_modifiers',
    'The class {0} should be {1}.',
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

  late final _libraryClasses = [
    for (final unit in context.allUnits)
      ...unit.unit.declarations.whereType<ClassDeclaration>(),
  ];

  late final _blocRelatedBaseElements = _collectBlocRelatedBaseElements();

  @override
  void visitClassDeclaration(ClassDeclaration node) {
    final element = node.declaredFragment?.element;
    if (element == null || !_isBlocRelatedClass(element)) {
      return;
    }

    final expectedModifier = _hasSubclasses(element)
        ? _ClassModifier.sealed_
        : _ClassModifier.final_;

    if (expectedModifier.isPresentOn(node)) {
      return;
    }

    rule.reportAtToken(
      node.namePart.typeName,
      arguments: [node.namePart.typeName.lexeme, expectedModifier.keyword],
    );
  }

  Set<InterfaceElement> _collectBlocRelatedBaseElements() {
    final elements = <InterfaceElement>{};

    for (final declaration in _libraryClasses) {
      final blocInfo = getBlocInfo(declaration);
      if (blocInfo == null) {
        continue;
      }

      void register(TypeAnnotation? type) {
        final element = _interfaceElement(type);
        if (element != null) {
          elements.add(element);
        }
      }

      register(blocInfo.stateType);
      register(blocInfo.eventType);
      register(blocInfo.presentationEventType);
    }

    return elements;
  }

  bool _isBlocRelatedClass(InterfaceElement element) =>
      _blocRelatedBaseElements.any(
        (base) =>
            TypeChecker.fromStatic(base.thisType).isAssignableFrom(element),
      );

  bool _hasSubclasses(InterfaceElement element) {
    final checker = TypeChecker.fromStatic(element.thisType);

    return _libraryClasses.any((declaration) {
      final subclassElement = declaration.declaredFragment?.element;

      return subclassElement != null && checker.isSuperOf(subclassElement);
    });
  }
}

InterfaceElement? _interfaceElement(TypeAnnotation? type) => switch (type) {
  NamedType(:final InterfaceElement element) => element,
  _ => null,
};

enum _ClassModifier {
  sealed_('sealed'),
  final_('final');

  const _ClassModifier(this.keyword);

  final String keyword;

  bool isPresentOn(ClassDeclaration node) => switch (this) {
    sealed_ => node.sealedKeyword != null,
    final_ => node.finalKeyword != null,
  };
}
