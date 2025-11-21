import 'package:analysis_server_plugin/edit/dart/correction_producer.dart';
import 'package:analysis_server_plugin/edit/dart/dart_fix_kind_priority.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer_plugin/utilities/assist/assist.dart';
import 'package:analyzer_plugin/utilities/change_builder/change_builder_core.dart';
import 'package:analyzer_plugin/utilities/range_factory.dart';
import 'package:leancode_lint/helpers.dart';
import 'package:leancode_lint/type_checker.dart';

/// Converts an iterable call to [Iterable.map] with an optional
/// collect [Iterable.toList]/[Iterable.toSet] to a collection-for idiom.
///
/// **Example**:
///
/// ```dart
/// final iterable = [1, 2, 3];
/// final someList = iterable.map((e) => e * 2).toList();
/// final someSet = iterable.map((e) => e / 2).toSet();
/// ```
///
/// When assist is applied to `someList` and `someSet` the result is
///
/// ```dart
/// final iterable = [1, 2, 3];
/// final someList = [for(final e in iterable) e * 2];
/// final someSet = {for(final e in iterable) e / 2};
/// ```
class ConvertIterableMapToCollectionFor extends ResolvedCorrectionProducer {
  ConvertIterableMapToCollectionFor({required super.context});

  @override
  AssistKind? get assistKind => const .new(
    'leancode_lint.assist.convertIterableMapToCollectionFor',
    DartFixKindPriority.standard,
    'Turn into collection-for',
  );

  @override
  CorrectionApplicability get applicability => .automatically;

  @override
  Future<void> compute(ChangeBuilder builder) async {
    if (node case final MethodInvocation node) {
      _handleIterable(node, builder);
    }
  }

  void _handleIterable(MethodInvocation node, ChangeBuilder builder) {
    const iterableChecker = TypeChecker.fromUrl('dart:core#Iterable');

    if (node case MethodInvocation(
      target: Expression(staticType: final targetType?) && final target,
      methodName: SimpleIdentifier(name: 'map'),
      :final parent,
      argumentList: ArgumentList(
        arguments: [
          FunctionExpression(
            body: final functionBody,
            parameters: FormalParameterList(parameters: [final parameter]),
          ),
        ],
      ),
    ) when iterableChecker.isAssignableFromType(targetType)) {
      final expression = maybeGetSingleReturnExpression(functionBody);
      if (expression == null) {
        return;
      }

      final parentCollectKind = _checkCollectKind(parent);
      final collectKind = parentCollectKind?.$1 ?? .list;
      final nodeWithCollect = parentCollectKind?.$2 ?? node;

      builder.addDartFileEdit(file, (builder) {
        builder
          ..addSimpleReplacement(
            range.startStart(nodeWithCollect, target),
            '${collectKind.startDelimiter}for(final $parameter in ',
          )
          ..addSimpleReplacement(
            range.endEnd(target, nodeWithCollect),
            ') $expression${collectKind.endDelimiter}',
          )
          ..format(range.node(nodeWithCollect));
      });
    }
  }

  (_IterableCollect, MethodInvocation)? _checkCollectKind(AstNode? parent) {
    return switch (parent) {
      ParenthesizedExpression(:final parent) => _checkCollectKind(parent),
      MethodInvocation(methodName: SimpleIdentifier(name: 'toList')) => (
        _IterableCollect.list,
        parent,
      ),
      MethodInvocation(methodName: SimpleIdentifier(name: 'toSet')) => (
        _IterableCollect.set,
        parent,
      ),
      _ => null,
    };
  }
}

enum _IterableCollect {
  list,
  set;

  String get startDelimiter => switch (this) {
    list => '[',
    set => '{',
  };

  String get endDelimiter => switch (this) {
    list => ']',
    set => '}',
  };
}
