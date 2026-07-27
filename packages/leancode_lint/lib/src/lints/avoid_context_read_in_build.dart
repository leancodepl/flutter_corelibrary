import 'package:analysis_server_plugin/edit/dart/correction_producer.dart';
import 'package:analysis_server_plugin/edit/dart/dart_fix_kind_priority.dart';
import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/error/error.dart';
import 'package:analyzer_plugin/utilities/change_builder/change_builder_core.dart';
import 'package:analyzer_plugin/utilities/fixes/fixes.dart';
import 'package:analyzer_plugin/utilities/range_factory.dart';
import 'package:leancode_lint/src/helpers.dart';
import 'package:leancode_lint/src/type_checker.dart';

/// Warns when `context.read` is called during `build`.
///
/// `read` grabs a value once and never re-subscribes, so using its result to
/// render leaves the UI stale when the value changes — `watch` (or a
/// `BlocBuilder`/`BlocSelector`) is what's actually wanted.
///
/// Every `read` that executes during build is reported, whatever it is used
/// for: reading a value, calling a method, or grabbing a bloc/service
/// reference. All three run on every rebuild, so none of them belong in
/// `build`. Reads inside deferred interaction callbacks (`onTap`, `onPressed`)
/// are exempt — that is where `read` is meant to be used; reads inside builder
/// closures that run during build are checked.
class AvoidContextReadInBuild extends AnalysisRule {
  AvoidContextReadInBuild()
    : super(name: code.lowerCaseName, description: code.problemMessage);

  static const code = LintCode(
    'avoid_context_read_in_build',
    "Avoid using 'context.read' inside 'build' method.",
    correctionMessage:
        "Use 'context.watch' (or BlocBuilder/BlocSelector) to consume the value, or move the read into a callback.",
    severity: .WARNING,
  );

  @override
  LintCode get diagnosticCode => code;

  @override
  void registerNodeProcessors(
    RuleVisitorRegistry registry,
    RuleContext context,
  ) {
    registry.addMethodInvocation(this, _Visitor(this));
  }
}

class _Visitor extends SimpleAstVisitor<void> {
  _Visitor(this.rule);

  final AnalysisRule rule;

  static const _buildContextChecker = TypeChecker.fromName(
    'BuildContext',
    packageName: 'flutter',
  );

  @override
  void visitMethodInvocation(MethodInvocation node) {
    if (node.methodName.name != 'read') {
      return;
    }
    final targetType = node.realTarget?.staticType;
    if (targetType == null ||
        !_buildContextChecker.isAssignableFromType(targetType)) {
      return;
    }

    if (!_runsDuringBuild(node)) {
      return;
    }

    rule.reportAtNode(node.methodName);
  }

  /// Whether [node] executes during build: it is inside a widget's `build`
  /// method, and every closure between [node] and that method declares a
  /// `BuildContext` parameter (i.e. is a builder that runs during build, not a
  /// deferred interaction callback).
  bool _runsDuringBuild(AstNode node) {
    for (
      AstNode? current = node.parent;
      current != null;
      current = current.parent
    ) {
      if (current is FunctionExpression &&
          !_declaresBuildContextParameter(current)) {
        return false;
      }
      if (current is MethodDeclaration) {
        if (current.name.lexeme != 'build') {
          return false;
        }
        final classDeclaration = current
            .thisOrAncestorOfType<ClassDeclaration>();
        return classDeclaration != null && isWidgetClass(classDeclaration);
      }
    }
    return false;
  }

  bool _declaresBuildContextParameter(FunctionExpression function) {
    final parameters = function.parameters?.parameters;
    if (parameters == null) {
      return false;
    }
    for (final parameter in parameters) {
      final type = parameter.declaredFragment?.element.type;
      if (type != null && _buildContextChecker.isAssignableFromType(type)) {
        return true;
      }
    }
    return false;
  }
}

class ReplaceContextReadWithWatchFix extends ResolvedCorrectionProducer {
  ReplaceContextReadWithWatchFix({required super.context});

  @override
  FixKind get fixKind => const .new(
    'leancode_lint.fix.replaceContextReadWithWatch',
    DartFixKindPriority.standard,
    "Replace with 'context.watch'",
  );

  @override
  CorrectionApplicability get applicability => .singleLocation;

  @override
  Future<void> compute(ChangeBuilder builder) async {
    await builder.addDartFileEdit(
      file,
      (builder) =>
          builder.addSimpleReplacement(range.diagnostic(diagnostic!), 'watch'),
    );
  }
}
