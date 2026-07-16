import 'package:analysis_server_plugin/edit/dart/correction_producer.dart';
import 'package:analysis_server_plugin/edit/dart/dart_fix_kind_priority.dart';
import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:analyzer/error/error.dart';
import 'package:analyzer_plugin/utilities/change_builder/change_builder_core.dart';
import 'package:analyzer_plugin/utilities/fixes/fixes.dart';
import 'package:analyzer_plugin/utilities/range_factory.dart';
import 'package:leancode_lint/src/helpers.dart';
import 'package:leancode_lint/src/type_checker.dart';

/// Warns when `context.read` is used to consume reactive data during `build`.
///
/// `read` grabs a value once and never re-subscribes, so using its result to
/// render leaves the UI stale when the value changes — `watch` (or a
/// `BlocBuilder`/`BlocSelector`) is what's actually wanted.
///
/// The rule is deliberately narrow: it does not flag the many legitimate uses
/// of `context.read` in `build` — calling methods, adding bloc events, or
/// grabbing a bloc/service reference. Only reads whose value is consumed as
/// data (a getter/property read, or a plain non-bloc value used directly) are
/// reported. Reads inside deferred interaction callbacks (`onTap`, `onPressed`)
/// are exempt; reads inside builder closures that run during build are checked.
class AvoidContextReadInBuild extends AnalysisRule {
  AvoidContextReadInBuild()
    : super(name: code.lowerCaseName, description: code.problemMessage);

  static const code = LintCode(
    'avoid_context_read_in_build',
    "Avoid reading reactive data with 'context.read' inside 'build' method.",
    correctionMessage:
        "Use 'context.watch' (or BlocBuilder/BlocSelector) so the widget rebuilds when the value changes.",
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

  static const _blocChecker = TypeChecker.any([
    .fromName('BlocBase', packageName: 'bloc'),
    .fromName('Cubit', packageName: 'bloc'),
    .fromName('Bloc', packageName: 'bloc'),
  ]);

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

    // The read itself must execute during build.
    if (!_runsDuringBuild(node)) {
      return;
    }

    final parent = node.parent;
    if (parent is VariableDeclaration && identical(parent.initializer, node)) {
      _checkTracedVariable(node, parent);
      return;
    }

    if (_isReactiveDataUse(node, node.staticType)) {
      rule.reportAtNode(node.methodName);
    }
  }

  /// Follows a local variable initialized directly from the read and reports
  /// once if any of its references (that run during build) consume reactive
  /// data.
  void _checkTracedVariable(MethodInvocation node, VariableDeclaration decl) {
    final element = decl.declaredFragment?.element;
    final buildMethod = node.thisOrAncestorOfType<MethodDeclaration>();
    if (element == null || buildMethod == null) {
      return;
    }

    final references = _ReferenceGatherer.gather(buildMethod.body, element);
    for (final reference in references) {
      if (_runsDuringBuild(reference) &&
          _isReactiveDataUse(reference, reference.staticType)) {
        rule.reportAtNode(node.methodName);
        return;
      }
    }
  }

  /// Whether [occurrence] (the read expression or a reference to a traced
  /// variable) is consumed as reactive data.
  bool _isReactiveDataUse(Expression occurrence, DartType? type) {
    final parent = occurrence.parent;

    // Method-call/cascade receiver: `x.doThing()`, `x.add(e)` — a side effect,
    // not a data read.
    if (parent is MethodInvocation &&
        identical(parent.realTarget, occurrence)) {
      return false;
    }
    if (parent is CascadeExpression && identical(parent.target, occurrence)) {
      return false;
    }

    // Member access: a getter/field read (`x.state`, `x.value`) consumes data,
    // but a method tear-off (`x.increment`) is just a reference to call later.
    if (parent is PropertyAccess && identical(parent.realTarget, occurrence)) {
      return parent.propertyName.element is! MethodElement;
    }
    if (parent is PrefixedIdentifier && identical(parent.prefix, occurrence)) {
      return parent.identifier.element is! MethodElement;
    }

    // Used directly as a plain value (argument, interpolation, return, ...):
    // flag only when it is not a bloc/cubit object reference.
    return type != null && !_blocChecker.isAssignableFromType(type);
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

/// Gathers every simple identifier within a subtree that resolves to a given
/// element.
class _ReferenceGatherer extends RecursiveAstVisitor<void> {
  _ReferenceGatherer(this._element);

  final Element _element;
  final List<SimpleIdentifier> _references = [];

  static List<SimpleIdentifier> gather(AstNode root, Element element) {
    final gatherer = _ReferenceGatherer(element);
    root.accept(gatherer);
    return gatherer._references;
  }

  @override
  void visitSimpleIdentifier(SimpleIdentifier node) {
    if (identical(node.element, _element)) {
      _references.add(node);
    }
    super.visitSimpleIdentifier(node);
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
  CorrectionApplicability get applicability => .automatically;

  @override
  Future<void> compute(ChangeBuilder builder) async {
    await builder.addDartFileEdit(
      file,
      (builder) =>
          builder.addSimpleReplacement(range.diagnostic(diagnostic!), 'watch'),
    );
  }
}
