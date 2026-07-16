import 'package:analysis_server_plugin/edit/dart/correction_producer.dart';
import 'package:analysis_server_plugin/edit/dart/dart_fix_kind_priority.dart';
import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/token.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:analyzer/error/error.dart';
import 'package:analyzer/workspace/workspace.dart';
import 'package:analyzer_plugin/utilities/change_builder/change_builder_core.dart';
import 'package:analyzer_plugin/utilities/fixes/fixes.dart';
import 'package:analyzer_plugin/utilities/range_factory.dart';
import 'package:leancode_lint/src/type_checker.dart';
import 'package:yaml/yaml.dart';

/// Displays a warning when collections are compared directly with `==` or `!=`.
class AvoidDirectCollectionEqualityChecks extends AnalysisRule {
  AvoidDirectCollectionEqualityChecks()
    : super(name: code.lowerCaseName, description: code.problemMessage);

  static const code = LintCode(
    'avoid_direct_collection_equality_checks',
    'Avoid comparing {0}s directly with `==` or `!=`. This compares identity, not contents.',
    correctionMessage:
        'Use `{1}` or `const {2}().equals` to compare contents, or `identical` if an identity check is intended.',
    severity: .WARNING,
  );

  @override
  LintCode get diagnosticCode => code;

  @override
  void registerNodeProcessors(
    RuleVisitorRegistry registry,
    RuleContext context,
  ) {
    registry.addBinaryExpression(this, _Visitor(this));
  }
}

class _Visitor extends SimpleAstVisitor<void> {
  _Visitor(this.rule);

  final AnalysisRule rule;

  @override
  void visitBinaryExpression(BinaryExpression node) {
    final operator = node.operator.type;
    if (operator != TokenType.EQ_EQ && operator != TokenType.BANG_EQ) {
      return;
    }

    final leftKind = collectionKind(node.leftOperand.staticType);
    final rightKind = collectionKind(node.rightOperand.staticType);
    if (leftKind == null || leftKind != rightKind) {
      return;
    }

    rule.reportAtNode(
      node,
      arguments: [
        leftKind.displayName,
        leftKind.flutterFunction,
        leftKind.collectionClass,
      ],
    );
  }
}

/// The kind of a core collection type, used to pick the matching equality
/// helper for the quick fixes.
enum CollectionKind {
  list('List', flutterFunction: 'listEquals', collectionClass: 'ListEquality'),
  set('Set', flutterFunction: 'setEquals', collectionClass: 'SetEquality'),
  map('Map', flutterFunction: 'mapEquals', collectionClass: 'MapEquality');

  const CollectionKind(
    this.displayName, {
    required this.flutterFunction,
    required this.collectionClass,
  });

  /// The name used in the diagnostic message, e.g. `List`.
  final String displayName;

  /// The `package:flutter/foundation.dart` function, e.g. `listEquals`.
  final String flutterFunction;

  /// The `package:collection` equality class, e.g. `ListEquality`.
  final String collectionClass;
}

/// Returns the [CollectionKind] of [type] if it is (a subtype of) a core
/// `List`, `Set`, or `Map`, otherwise `null`.
CollectionKind? collectionKind(DartType? type) {
  if (type == null) {
    return null;
  }

  // `Map` is checked first because it is not an `Iterable`, while `Set` and
  // `List` both are.
  const map = TypeChecker.fromName('Map', packageName: 'dart:core');
  const set = TypeChecker.fromName('Set', packageName: 'dart:core');
  const list = TypeChecker.fromName('List', packageName: 'dart:core');

  if (map.isAssignableFromType(type)) {
    return CollectionKind.map;
  }
  if (set.isAssignableFromType(type)) {
    return CollectionKind.set;
  }
  if (list.isAssignableFromType(type)) {
    return CollectionKind.list;
  }
  return null;
}

/// Returns the [BinaryExpression] a collection-equality fix should rewrite, or
/// `null` if it cannot be resolved from [node].
BinaryExpression? _targetBinary(AstNode node) =>
    node.thisOrAncestorOfType<BinaryExpression>();

/// Replaces a direct collection equality check with the matching Flutter
/// `listEquals`/`setEquals`/`mapEquals` call.
class ReplaceWithFlutterFoundationEqualsFix extends ResolvedCorrectionProducer {
  ReplaceWithFlutterFoundationEqualsFix({required super.context});

  @override
  FixKind get fixKind => const .new(
    'leancode_lint.fix.replaceWithFlutterFoundationEquals',
    DartFixKindPriority.standard,
    "Replace with '{0}'",
  );

  @override
  List<String>? get fixArguments {
    final binary = _targetBinary(node);
    final kind = binary == null
        ? null
        : collectionKind(binary.leftOperand.staticType);
    return [(kind ?? CollectionKind.list).flutterFunction];
  }

  @override
  CorrectionApplicability get applicability => .automatically;

  @override
  Future<void> compute(ChangeBuilder builder) async {
    final binary = _targetBinary(node);
    if (binary == null) {
      return;
    }

    final kind = collectionKind(binary.leftOperand.staticType);
    if (kind == null) {
      return;
    }

    final negate = binary.operator.type == TokenType.BANG_EQ;
    final left = binary.leftOperand.toSource();
    final right = binary.rightOperand.toSource();

    await builder.addDartFileEdit(file, (builder) {
      builder
        ..importLibraryElement(.parse('package:flutter/foundation.dart'))
        ..addReplacement(
          range.node(binary),
          (builder) => builder.write(
            '${negate ? '!' : ''}${kind.flutterFunction}($left, $right)',
          ),
        )
        ..format(range.node(binary));
    });
  }
}

/// Replaces a direct collection equality check with the matching
/// `package:collection` equality, e.g. `const ListEquality().equals(a, b)`.
class ReplaceWithCollectionPackageEqualityFix
    extends ResolvedCorrectionProducer {
  ReplaceWithCollectionPackageEqualityFix({required super.context});

  @override
  FixKind get fixKind => const .new(
    'leancode_lint.fix.replaceWithCollectionPackageEquality',
    DartFixKindPriority.standard,
    "Replace with '{0}'",
  );

  @override
  List<String>? get fixArguments {
    final binary = _targetBinary(node);
    final kind = binary == null
        ? null
        : collectionKind(binary.leftOperand.staticType);
    return [(kind ?? CollectionKind.list).collectionClass];
  }

  @override
  CorrectionApplicability get applicability => .automatically;

  /// Whether the package that owns the analyzed file directly depends on
  /// `package:collection`. Transitive dependencies do not count, since the
  /// rewrite must not introduce an import the package cannot resolve on its
  /// own.
  bool get _dependsOnCollection {
    final WorkspacePackage? package = sessionHelper
        .session
        .analysisContext
        .contextRoot
        .workspace
        .findPackageFor(file);
    final pubspec = package?.root.getFile('pubspec.yaml');
    if (pubspec == null || !pubspec.exists) {
      return false;
    }

    final YamlNode document;
    try {
      document = loadYamlNode(pubspec.readAsStringSync());
    } on Exception {
      return false;
    }
    if (document is! YamlMap) {
      return false;
    }

    final dependencies = document['dependencies'];
    return dependencies is YamlMap && dependencies.containsKey('collection');
  }

  @override
  Future<void> compute(ChangeBuilder builder) async {
    final binary = _targetBinary(node);
    if (binary == null) {
      return;
    }

    if (!_dependsOnCollection) {
      return;
    }

    final leftType = binary.leftOperand.staticType;
    final kind = collectionKind(leftType);
    if (kind == null) {
      return;
    }

    // Resolve the collection's type arguments (e.g. `int` for `List<int>`) so
    // the generated constructor is `const ListEquality<int>()` rather than a
    // raw `const ListEquality()`, which fails type inference.
    final collectionElement = switch (kind) {
      CollectionKind.list => typeProvider.listElement,
      CollectionKind.set => typeProvider.setElement,
      CollectionKind.map => typeProvider.mapElement,
    };
    final typeArguments = leftType is InterfaceType
        ? leftType.asInstanceOf(collectionElement)?.typeArguments ?? const []
        : const <DartType>[];

    final negate = binary.operator.type == TokenType.BANG_EQ;
    final left = binary.leftOperand.toSource();
    final right = binary.rightOperand.toSource();

    await builder.addDartFileEdit(file, (builder) {
      builder
        ..importLibraryElement(.parse('package:collection/collection.dart'))
        ..addReplacement(range.node(binary), (builder) {
          if (negate) {
            builder.write('!');
          }
          builder.write('const ${kind.collectionClass}');
          if (typeArguments.isNotEmpty) {
            builder.write('<');
            for (var i = 0; i < typeArguments.length; i++) {
              if (i > 0) {
                builder.write(', ');
              }
              builder.writeType(typeArguments[i], shouldWriteDynamic: true);
            }
            builder.write('>');
          }
          builder.write('().equals($left, $right)');
        })
        ..format(range.node(binary));
    });
  }
}

/// Replaces a direct collection equality check with an `identical` call, for
/// the cases where an identity comparison is actually intended.
class ReplaceWithIdenticalFix extends ResolvedCorrectionProducer {
  ReplaceWithIdenticalFix({required super.context});

  @override
  FixKind get fixKind => const .new(
    'leancode_lint.fix.replaceWithIdentical',
    DartFixKindPriority.standard,
    "Replace with 'identical'",
  );

  @override
  CorrectionApplicability get applicability => .automatically;

  @override
  Future<void> compute(ChangeBuilder builder) async {
    final binary = _targetBinary(node);
    if (binary == null) {
      return;
    }

    final negate = binary.operator.type == TokenType.BANG_EQ;
    final left = binary.leftOperand.toSource();
    final right = binary.rightOperand.toSource();

    await builder.addDartFileEdit(file, (builder) {
      builder
        ..addReplacement(
          range.node(binary),
          (builder) =>
              builder.write('${negate ? '!' : ''}identical($left, $right)'),
        )
        ..format(range.node(binary));
    });
  }
}
