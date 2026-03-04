import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/error/error.dart';
import 'package:leancode_lint/src/bloc_utils.dart';
import 'package:leancode_lint/src/type_checker.dart';

/// Ensures that subclasses of a bloc state, event, or presentation event class
/// are prefixed with the name of the base class.
///
/// Given a BLoC named `FooBloc` with a state class `FooState` and event class
/// `FooEvent`, all their subclasses must start with the respective base name:
/// - `FooState` subclasses → `FooStateInitial`, `FooStateLoaded`, …
/// - `FooEvent` subclasses → `FooEventLoad`, `FooEventReset`, …
/// - `FooPresentationEvent` subclasses → `FooPresentationEventSuccess`, …
class BlocSubclassesNaming extends AnalysisRule {
  BlocSubclassesNaming()
    : super(name: code.lowerCaseName, description: code.problemMessage);

  static const code = LintCode(
    'bloc_subclasses_naming',
    "Subclass of '{0}' should be prefixed with '{0}' (e.g. '{0}MySubclass').",
    severity: .WARNING,
  );

  @override
  LintCode get diagnosticCode => code;

  @override
  void registerNodeProcessors(
    RuleVisitorRegistry registry,
    RuleContext context,
  ) {
    registry.addCompilationUnit(this, _Visitor(this, context));
  }
}

class _Visitor extends SimpleAstVisitor<void> {
  _Visitor(this.rule, this.context);

  final AnalysisRule rule;
  final RuleContext context;

  @override
  void visitCompilationUnit(CompilationUnit node) {
    final classes = node.declarations.whereType<ClassDeclaration>();

    // Collect the direct state/event/presentationEvent elements of every
    // BLoC/Cubit in the compilation unit, paired with their name.
    final blocRelatedBases = <({TypeChecker checker, String baseName})>[];

    for (final declaration in classes) {
      final blocInfo = getBlocInfo(declaration);
      if (blocInfo == null) {
        continue;
      }

      void register(TypeAnnotation? type) {
        if (type case NamedType(
          :final name,
          :final InterfaceElement element?,
        )) {
          blocRelatedBases.add((
            checker: .fromStatic(element.thisType),
            baseName: name.lexeme,
          ));
        }
      }

      register(blocInfo.stateType);
      register(blocInfo.eventType);
      register(blocInfo.presentationEventType);
    }

    if (blocRelatedBases.isEmpty) {
      return;
    }

    // For each class, find the closest bloc-related ancestor (if any) and
    // check that the class name is prefixed with that ancestor's name.
    // Nested hierarchies are handled by TypeChecker.isSuperOf.
    for (final declaration in classes) {
      final element = declaration.declaredFragment?.element;
      if (element == null) {
        continue;
      }

      for (final (:checker, :baseName) in blocRelatedBases) {
        if (!checker.isSuperOf(element)) {
          continue;
        }

        final className = declaration.namePart.typeName.lexeme;
        if (!className.startsWith(baseName)) {
          rule.reportAtToken(
            declaration.namePart.typeName,
            arguments: [baseName],
          );
        }

        // A class can only descend from one bloc-related base.
        break;
      }
    }
  }
}
