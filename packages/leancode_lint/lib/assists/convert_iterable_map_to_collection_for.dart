import 'package:analysis_server_plugin/edit/dart/correction_producer.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/source/source_range.dart';
import 'package:analyzer_plugin/utilities/assist/assist.dart';
import 'package:analyzer_plugin/utilities/change_builder/change_builder_core.dart';
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
  AssistKind? get assistKind => const AssistKind(
    'leancode.lint.convertIterableMapToCollectionFor',
    50,
    'Convert to collection-for',
  );

  @override
  CorrectionApplicability get applicability =>
      CorrectionApplicability.singleLocation;

  @override
  Future<void> compute(ChangeBuilder builder) async {
    if (node case final MethodInvocation node) {
      _handleIterable(node, file, builder);
    }
  }

  void _handleIterable(
    MethodInvocation node,
    String file,
    ChangeBuilder builder,
  ) {
    const iterableChecker = TypeChecker.fromUrl('dart:core#Iterable');

    if (node case MethodInvocation(
      target: Expression(
        staticType: final targetType?,
        offset: final targetOffset,
        end: final targetEnd,
      ),
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
      final collectKind = parentCollectKind?.$1 ?? _IterableCollect.list;
      final nodeWithCollect = parentCollectKind?.$2 ?? node;

      builder.addDartFileEdit(file, (builder) {
        builder
          ..addSimpleReplacement(
            SourceRange(
              nodeWithCollect.offset,
              targetOffset - nodeWithCollect.offset,
            ),
            '${collectKind.startDelimiter}for(final $parameter in ',
          )
          ..addSimpleReplacement(
            SourceRange(targetEnd, nodeWithCollect.end - targetEnd),
            ') $expression${collectKind.endDelimiter}',
          )
          ..format(nodeWithCollect.sourceRange);
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
