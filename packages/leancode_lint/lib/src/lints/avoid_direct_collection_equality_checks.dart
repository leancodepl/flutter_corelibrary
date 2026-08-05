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
import 'package:analyzer_plugin/utilities/change_builder/change_builder_core.dart';
import 'package:analyzer_plugin/utilities/fixes/fixes.dart';
import 'package:analyzer_plugin/utilities/range_factory.dart';
import 'package:leancode_lint/src/helpers.dart';

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

enum CollectionKind {
  list('List', flutterFunction: 'listEquals', collectionClass: 'ListEquality'),
  set('Set', flutterFunction: 'setEquals', collectionClass: 'SetEquality'),
  map('Map', flutterFunction: 'mapEquals', collectionClass: 'MapEquality');

  const CollectionKind(
    this.displayName, {
    required this.flutterFunction,
    required this.collectionClass,
  });

  final String displayName;

  /// From `package:flutter/foundation.dart`.
  final String flutterFunction;

  /// From `package:collection`.
  final String collectionClass;
}

/// Also matches subtypes of `List`, `Set` and `Map`.
CollectionKind? collectionKind(DartType? type) {
  if (type is! InterfaceType) {
    return null;
  }

  final types = [type, ...type.allSupertypes];

  if (types.any((it) => it.isDartCoreMap)) {
    return CollectionKind.map;
  }
  if (types.any((it) => it.isDartCoreSet)) {
    return CollectionKind.set;
  }
  if (types.any((it) => it.isDartCoreList)) {
    return CollectionKind.list;
  }
  return null;
}

const _flutterFoundationUri = 'package:flutter/foundation.dart';
const _collectionUri = 'package:collection/collection.dart';

BinaryExpression? _targetBinary(AstNode node) =>
    node.thisOrAncestorOfType<BinaryExpression>();

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
    final binary = _targetBinary(node)!;
    final kind = collectionKind(binary.leftOperand.staticType)!;
    return [kind.flutterFunction];
  }

  @override
  CorrectionApplicability get applicability => .automatically;

  @override
  Future<void> compute(ChangeBuilder builder) async {
    final binary = _targetBinary(node);
    if (binary == null) {
      return;
    }

    if (!dependsOnPackage('flutter')) {
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
        ..importLibraryElement(.parse(_flutterFoundationUri))
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
    final binary = _targetBinary(node)!;
    final kind = collectionKind(binary.leftOperand.staticType)!;
    return [kind.collectionClass];
  }

  @override
  CorrectionApplicability get applicability => .automatically;

  @override
  Future<void> compute(ChangeBuilder builder) async {
    final binary = _targetBinary(node);
    if (binary == null) {
      return;
    }

    if (!dependsOnPackage('collection')) {
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
      .list => typeProvider.listElement,
      .set => typeProvider.setElement,
      .map => typeProvider.mapElement,
    };
    final typeArguments = leftType is InterfaceType
        ? leftType.asInstanceOf(collectionElement)?.typeArguments ?? const []
        : const <DartType>[];

    final negate = binary.operator.type == TokenType.BANG_EQ;
    final left = binary.leftOperand.toSource();
    final right = binary.rightOperand.toSource();

    await builder.addDartFileEdit(file, (builder) {
      builder
        ..importLibraryElement(.parse(_collectionUri))
        ..addReplacement(range.node(binary), (builder) {
          if (negate) {
            builder.write('!');
          }
          builder.write('const ${kind.collectionClass}');
          if (typeArguments.isNotEmpty) {
            builder
              ..writeTypes(
                typeArguments,
                prefix: '<',
                shouldWriteDynamic: true,
              )
              ..write('>');
          }
          builder.write('().equals($left, $right)');
        })
        ..format(range.node(binary));
    });
  }
}

/// For the cases where an identity comparison is actually intended.
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
