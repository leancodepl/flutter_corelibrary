// import 'package:analyzer/dart/ast/syntactic_entity.dart';
// import 'package:analyzer/dart/ast/token.dart';
// import 'package:analyzer/source/source_range.dart';
// import 'package:custom_lint_builder/custom_lint_builder.dart';
// import 'package:leancode_lint/utils.dart';
//
// /// Converts required positional parameters to named ones.
// ///
// /// **Example**:
// ///
// /// ```dart
// /// class MyType<T extends Object> {
// ///   const MyType(
// ///     this.pos0,
// ///     this.hello, {
// ///     this.named1,
// ///   });
// ///
// ///   final String pos0;
// ///   final OtherType hello;
// ///   final int? named1;
// /// }
// /// ```
// ///
// /// When applied to `pos0`, the result is
// ///
// /// ```dart
// /// class MyType<T extends Object> {
// ///   const MyType(
// ///     this.hello, {
// ///     required this.pos0,
// ///     this.named1,
// ///   });
// ///
// ///   final String pos0;
// ///   final OtherType hello;
// ///   final int? named1;
// /// }
// /// ```
// class ConvertPositionalToNamedFormal extends DartAssist {
//   @override
//   void run(
//     CustomLintResolver resolver,
//     ChangeReporter reporter,
//     CustomLintContext context,
//     SourceRange target,
//   ) {
//     context.registry.addFormalParameterList((node) {
//       // parameter list has positional optional parameters, named params cannot be added
//       if (node.leftDelimiter?.kind == TokenType.OPEN_SQUARE_BRACKET.kind) {
//         return;
//       }
//
//       final parameters = node.parameters.where(
//         (parameter) => parameter.isRequiredPositional,
//       );
//
//       final nextItem = parameters.skip(1).cast<SyntacticEntity>().followedBy([
//         node.leftDelimiter ?? node.rightParenthesis,
//       ]);
//
//       final found = parameters
//           .zip(nextItem)
//           .map(
//             (e) => (e.$1, SourceRange(e.$1.offset, e.$2.offset - e.$1.offset)),
//           )
//           .firstWhereOrNull((e) => target.intersects(e.$2));
//
//       if (found == null) {
//         return;
//       }
//
//       final (parameter, sourceRange) = found;
//
//       reporter
//           .createChangeBuilder(
//             message: 'Convert to named formal parameter',
//             priority: 1,
//           )
//           .addDartFileEdit((builder) {
//             // delete positional parameter
//             builder.addDeletion(sourceRange);
//
//             final namedParam =
//                 '${Keyword.REQUIRED.lexeme} ${Keyword.THIS.lexeme}.${parameter.name},';
//
//             if (node.leftDelimiter case final brace?) {
//               // has named parameters, add to list
//               builder.addSimpleInsertion(brace.offset + 1, namedParam);
//             } else {
//               // no named parameters, create
//               builder.addSimpleInsertion(
//                 node.rightParenthesis.offset,
//                 '{$namedParam}',
//               );
//             }
//
//             builder.format(node.sourceRange);
//           });
//     });
//   }
// }
