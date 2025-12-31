import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/diagnostic/diagnostic.dart';
import 'package:analyzer/source/source_range.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';
import 'package:leancode_lint/lints/catch_parameter_names.dart';

class RenameCatchParameter extends DartFix {
  RenameCatchParameter(this.config);

  final CatchParameterNamesConfig config;

  @override
  Future<void> run(
      CustomLintResolver resolver,
      ChangeReporter reporter,
      CustomLintContext context,
      Diagnostic analysisError,
      List<Diagnostic> others,
      ) async {
    // Get the resolved unit directly
    final result = await resolver.getResolvedUnitResult();
    final unit = result.unit;

    // Find the catch clause containing the error
    final node = unit.nodeCovering(offset: analysisError.offset);
    final catchClause = node?.thisOrAncestorOfType<CatchClause>();

    if (catchClause == null) {
      return;
    }

    // Determine which parameter needs renaming based on error location
    final (targetParam, isException) = _identifyTargetParameter(catchClause, analysisError.offset);

    if (targetParam == null) {
      return;
    }

    final oldName = targetParam.name.lexeme;
    final newName = isException ? config.exceptionName : config.stackTraceName;

    if (oldName == newName || oldName == '_') {
      return;
    }

    // Collect all occurrences to rename
    final occurrences = _collectOccurrences(catchClause, targetParam, oldName);

    if (occurrences.isEmpty) {
      return;
    }

    // Apply the rename
    reporter
        .createChangeBuilder(message: 'Rename `$oldName` to `$newName`', priority: 80)
        .addDartFileEdit((builder) {
      // Apply replacements in reverse order to maintain offsets
      for (final range in occurrences.reversed) {
        builder.addSimpleReplacement(range, newName);
      }
    });
  }

  /// Identifies which parameter (exception or stack trace) is being flagged.
  /// Returns (parameter, isException) or (null, false) if not found.
  (CatchClauseParameter?, bool) _identifyTargetParameter(CatchClause catchClause, int errorOffset) {
    final exceptionParam = catchClause.exceptionParameter;
    final stackParam = catchClause.stackTraceParameter;

    if (exceptionParam != null && _containsOffset(exceptionParam, errorOffset)) {
      return (exceptionParam, true);
    }

    if (stackParam != null && _containsOffset(stackParam, errorOffset)) {
      return (stackParam, false);
    }

    return (null, false);
  }

  bool _containsOffset(CatchClauseParameter param, int offset) {
    return offset >= param.offset && offset < param.end;
  }

  /// Collects all occurrences of the parameter that need to be renamed.
  List<SourceRange> _collectOccurrences(
      CatchClause catchClause,
      CatchClauseParameter targetParam,
      String oldName,
      ) {
    final occurrences = <SourceRange>[];
    final targetElement = targetParam.declaredFragment?.element;

    // Add the declaration itself
    occurrences.add(SourceRange(targetParam.name.offset, targetParam.name.length));

    // Find all usages in the catch body
    final visitor = _UsageFinder(
      oldName: oldName,
      targetElement: targetElement,
      declarationOffset: targetParam.name.offset,
      catchClause: catchClause,
    );

    catchClause.body.visitChildren(visitor);
    occurrences.addAll(visitor.occurrences);

    return occurrences;
  }
}

/// Visitor that finds all usages of a catch parameter within its scope,
/// accounting for shadowing by nested declarations.
class _UsageFinder extends RecursiveAstVisitor<void> {
  _UsageFinder({
    required this.oldName,
    required this.targetElement,
    required this.declarationOffset,
    required this.catchClause,
  });

  final String oldName;
  final Element? targetElement;
  final int declarationOffset;
  final CatchClause catchClause;
  final List<SourceRange> occurrences = [];

  @override
  void visitSimpleIdentifier(SimpleIdentifier node) {
    // Skip the declaration itself
    if (node.offset == declarationOffset) {
      return;
    }

    // Only rename if the name matches
    if (node.name != oldName) {
      return;
    }

    // Use element comparison for accuracy when available
    if (targetElement != null && node.element != null) {
      if (node.element == targetElement) {
        occurrences.add(SourceRange(node.offset, node.length));
      }
    } else {
      // Fallback to name-based matching (when element resolution unavailable)
      // This is safe within the same catch clause scope
      occurrences.add(SourceRange(node.offset, node.length));
    }

    super.visitSimpleIdentifier(node);
  }

  @override
  void visitCatchClause(CatchClause node) {
    // Don't descend into nested catch clauses - they have their own scope
    // and might shadow our parameter
    if (node != catchClause) {
      // Check if this nested catch shadows our parameter
      final exceptionName = node.exceptionParameter?.name.lexeme;
      final stackName = node.stackTraceParameter?.name.lexeme;

      if (exceptionName == oldName || stackName == oldName) {
        // Parameter is shadowed in this nested catch - don't visit it
        return;
      }
    }

    super.visitCatchClause(node);
  }

  @override
  void visitFunctionDeclaration(FunctionDeclaration node) {
    // Check if any parameter shadows our variable
    if (_functionShadowsParameter(node)) {
      return;
    }
    super.visitFunctionDeclaration(node);
  }

  @override
  void visitFunctionExpression(FunctionExpression node) {
    // Check if any parameter shadows our variable
    if (_functionExpressionShadowsParameter(node)) {
      return;
    }
    super.visitFunctionExpression(node);
  }

  bool _functionShadowsParameter(FunctionDeclaration node) {
    final params = node.functionExpression.parameters?.parameters;
    if (params == null) {
      return false;
    }

    return params.any((p) => p.name?.lexeme == oldName);
  }

  bool _functionExpressionShadowsParameter(FunctionExpression node) {
    final params = node.parameters?.parameters;
    if (params == null) {
      return false;
    }

    return params.any((p) => p.name?.lexeme == oldName);
  }
}
