import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/source/source_range.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';
import 'package:leancode_lint/helpers.dart';

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
class ConvertIterableMapToCollectionFor extends DartAssist {
  @override
  void run(
    CustomLintResolver resolver,
    ChangeReporter reporter,
    CustomLintContext context,
    SourceRange target,
  ) {
    context.registry.addMethodInvocation((node) {
      if (!target.intersects(node.sourceRange)) {
        return;
      }

      _handleIterable(node, reporter);
    });
  }

  void _handleIterable(MethodInvocation node, ChangeReporter reporter) {
    const iterableChecker = TypeChecker.fromUrl('dart:core#Iterable');

    if (node
        case MethodInvocation(
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
                parameters: FormalParameterList(parameters: [final parameter])
              )
            ]
          )
        ) when iterableChecker.isAssignableFromType(targetType)) {
      final expression = maybeGetSingleReturnExpression(functionBody);
      if (expression == null) {
        return;
      }

      final parentCollectKind = _checkCollectKind(parent);
      final collectKind = parentCollectKind?.$1 ?? _IterableCollect.list;
      final nodeWithCollect = parentCollectKind?.$2 ?? node;

      reporter
          .createChangeBuilder(
        message: 'Turn into collection-for',
        priority: 1,
      )
          .addDartFileEdit((builder) {
        builder
          ..addSimpleReplacement(
            SourceRange(
              nodeWithCollect.offset,
              targetOffset - nodeWithCollect.offset,
            ),
            '${collectKind.startDelimiter}for(final $parameter in ',
          )
          ..addSimpleReplacement(
            SourceRange(
              targetEnd,
              nodeWithCollect.end - targetEnd,
            ),
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
          parent
        ),
      MethodInvocation(methodName: SimpleIdentifier(name: 'toSet')) => (
          _IterableCollect.set,
          parent
        ),
      _ => null
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
