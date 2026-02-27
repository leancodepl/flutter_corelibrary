import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/error/error.dart';
import 'package:leancode_lint/config.dart';
import 'package:leancode_lint/src/bloc_utils.dart';
import 'package:leancode_lint/src/utils.dart';

/// Enforces consistent naming of state, event, and presentation event classes
/// related to a BLoC or Cubit.
///
/// Given a BLoC or Cubit named `FooBloc` or `FooCubit`, the associated classes
/// should be named:
/// - state → `FooState`
/// - event → `FooEvent`
/// - presentation event → `FooPresentationEvent`
///
/// The suffixes are configurable via [BlocRelatedClassNamingConfig].
class BlocRelatedClassNaming extends AnalysisRule {
  BlocRelatedClassNaming({this.config = const .new()})
    : super(name: code.lowerCaseName, description: code.problemMessage);

  final LeanCodeLintConfig config;

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
    registry.addClassDeclaration(this, _Visitor(this, context, config));
  }
}

class _Visitor extends SimpleAstVisitor<void> {
  _Visitor(this.rule, this.context, this.config);

  final AnalysisRule rule;
  final RuleContext context;
  final LeanCodeLintConfig config;

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

    void checkName(TypeAnnotation type, String classType, String suffix) {
      final expectedName = '$subject$suffix';

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
      checkName(stateType, 'state', config.blocRelatedClassNaming.stateSuffix);
    }

    if (blocInfo.eventType case final eventType?) {
      checkName(eventType, 'event', config.blocRelatedClassNaming.eventSuffix);
    }

    if (blocInfo.presentationEventType case final presentationEventType?) {
      checkName(
        presentationEventType,
        'presentation event',
        config.blocRelatedClassNaming.presentationEventSuffix,
      );
    }
  }
}
