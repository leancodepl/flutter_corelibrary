import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/error/error.dart';
import 'package:leancode_lint/src/bloc_utils.dart';
import 'package:leancode_lint/src/utils.dart';

class BlocRelatedClassNaming extends AnalysisRule {
  BlocRelatedClassNaming()
    : super(name: code.lowerCaseName, description: code.problemMessage);

  static const code = LintCode(
    'bloc_related_class_naming',
    "The name of {0}'s {1} should be {2}.",
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
    final blocInfo = getBlocInfo(node);
    if (blocInfo == null) {
      return;
    }

    final classElement = node.declaredFragment?.element;
    final className = node.namePart.typeName.lexeme;
    final subject = getBlocSubject(className, blocType: blocInfo.type);

    if (subject == null) {
      return;
    }

    void checkName(TypeAnnotation type, String classType, String expectedName) {
      if (type case NamedType(
        :final name,
        :final element?,
        :final CompilationUnit root,
      ) when name.lexeme != expectedName) {
        if (element.library != classElement?.library) {
          return;
        }

        final declaration = root.declarations
            .whereType<ClassDeclaration>()
            .firstWhereOrNull((d) => d.declaredFragment?.element == element);

        rule.reportAtToken(
          declaration?.namePart.typeName ?? name,
          arguments: [className, classType, expectedName],
        );
      }
    }

    if (blocInfo.stateType case final stateType?) {
      checkName(stateType, 'state', '${subject}State');
    }

    if (blocInfo.eventType case final eventType?) {
      checkName(eventType, 'event', '${subject}Event');
    }

    if (blocInfo.presentationEventType case final presentationEventType?) {
      final expectedPresentationEventName = blocInfo.type == .cubit
          ? '${subject}Event'
          : '${subject}PresentationEvent';
      checkName(
        presentationEventType,
        'presentation event',
        expectedPresentationEventName,
      );
    }
  }
}
