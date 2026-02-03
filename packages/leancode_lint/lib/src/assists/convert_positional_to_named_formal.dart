import 'package:analysis_server_plugin/edit/dart/correction_producer.dart';
import 'package:analysis_server_plugin/edit/dart/dart_fix_kind_priority.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/syntactic_entity.dart';
import 'package:analyzer/dart/ast/token.dart';
import 'package:analyzer/source/source_range.dart';
import 'package:analyzer_plugin/utilities/assist/assist.dart';
import 'package:analyzer_plugin/utilities/change_builder/change_builder_core.dart';
import 'package:analyzer_plugin/utilities/range_factory.dart';
import 'package:leancode_lint/src/utils.dart';

/// Converts required positional parameters to named ones.
///
/// **Example**:
///
/// ```dart
/// class MyType<T extends Object> {
///   const MyType(
///     this.pos0,
///     this.hello, {
///     this.named1,
///   });
///
///   final String pos0;
///   final OtherType hello;
///   final int? named1;
/// }
/// ```
///
/// When applied to `pos0`, the result is
///
/// ```dart
/// class MyType<T extends Object> {
///   const MyType(
///     this.hello, {
///     required this.pos0,
///     this.named1,
///   });
///
///   final String pos0;
///   final OtherType hello;
///   final int? named1;
/// }
/// ```
class ConvertPositionalToNamedFormal extends ResolvedCorrectionProducer {
  ConvertPositionalToNamedFormal({required super.context});

  @override
  AssistKind? get assistKind => const .new(
    'leancode_lint.assist.convertPositionalToNamedFormal',
    DartFixKindPriority.standard,
    'Convert to a named formal parameter',
  );

  @override
  CorrectionApplicability get applicability => .singleLocation;

  @override
  Future<void> compute(ChangeBuilder builder) async {
    if (node.thisOrAncestorOfType<FormalParameterList>() case final node?) {
      // parameter list has positional optional parameters, named params cannot be added
      if (node.leftDelimiter?.type == .OPEN_SQUARE_BRACKET) {
        return;
      }

      final parameters = node.parameters.where(
        (parameter) => parameter.isRequiredPositional,
      );

      final nextItem = parameters.skip(1).cast<SyntacticEntity>().followedBy([
        node.leftDelimiter ?? node.rightParenthesis,
      ]);

      final target = SourceRange(selectionOffset, selectionLength);
      final found = parameters
          .zip(nextItem)
          .map((e) => (e.$1, range.startStart(e.$1, e.$2)))
          .firstWhereOrNull((e) => target.intersects(e.$2));

      if (found == null) {
        return;
      }

      final (parameter, sourceRange) = found;

      await builder.addDartFileEdit(file, (builder) {
        // delete positional parameter
        builder.addDeletion(sourceRange);

        final namedParam =
            '${Keyword.REQUIRED.lexeme} ${Keyword.THIS.lexeme}.${parameter.name},';

        if (node.leftDelimiter case final brace?) {
          // has named parameters, add to list
          builder.addSimpleInsertion(brace.offset + 1, namedParam);
        } else {
          // no named parameters, create
          builder.addSimpleInsertion(
            node.rightParenthesis.offset,
            '{$namedParam}',
          );
        }

        builder.format(range.node(node));
      });
    }
  }
}
