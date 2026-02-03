// TODO: decide what to do with this lint in light of https://github.com/dart-lang/sdk/issues/61517

// import 'package:analyzer/dart/analysis/results.dart';
// import 'package:analyzer/dart/ast/ast.dart';
// import 'package:analyzer/dart/constant/value.dart';
// import 'package:analyzer/diagnostic/diagnostic.dart';
// import 'package:analyzer/error/listener.dart';
// import 'package:analyzer_plugin/utilities/range_factory.dart';
// import 'package:custom_lint_builder/custom_lint_builder.dart';
// import 'package:leancode_lint/helpers.dart';
//
// class PreferCenterOverAlign extends DartLintRule {
//   const PreferCenterOverAlign()
//     : super(
//         code: const LintCode(
//           name: 'prefer_center_over_align',
//           problemMessage:
//               'Use the Center widget instead of the Align widget with the alignment parameter set to Alignment.center',
//         ),
//       );
//
//   @override
//   List<Fix> getFixes() => [_PreferCenterOverAlignFix()];
//
//   static final _alignmentConstantKey = Object();
//
//   @override
//   Future<void> startUp(
//     CustomLintResolver resolver,
//     CustomLintContext context,
//   ) async {
//     final unit = await resolver.getResolvedUnitResult();
//     final session = unit.session;
//
//     final alignmentPath = session.uriConverter.uriToPath(
//       Uri.parse('package:flutter/src/painting/alignment.dart'),
//     );
//
//     if (alignmentPath != null) {
//       context.sharedState[_alignmentConstantKey] = switch (await session
//           .getResolvedLibrary(alignmentPath)) {
//         ResolvedLibraryResult(:final element) =>
//           element
//               .getClass('Alignment')
//               ?.getField('center')
//               ?.computeConstantValue(),
//         _ => null,
//       };
//     }
//
//     return super.startUp(resolver, context);
//   }
//
//   @override
//   void run(
//     CustomLintResolver resolver,
//     DiagnosticReporter reporter,
//     CustomLintContext context,
//   ) {
//     final centerConstantValue = context.sharedState[_alignmentConstantKey];
//     if (centerConstantValue is! DartObject) {
//       return;
//     }
//
//     context.registry.addInstanceCreationExpression((node) {
//       final data = _analyzeAlignInstanceCreationExpression(
//         node,
//         centerConstantValue,
//       );
//       if (data case final data? when data.isAlignmentCenter) {
//         reporter.atNode(node.constructorName, code, data: data);
//       }
//     });
//   }
//
//   _PreferCenterOverAlignData? _analyzeAlignInstanceCreationExpression(
//     InstanceCreationExpression node,
//     DartObject alignmentCenterConstantValue,
//   ) {
//     if (!isExpressionExactlyType(node, 'Align', 'flutter')) {
//       return null;
//     }
//     final arguments = node.argumentList.arguments;
//     var hasAlignmentArgument = false;
//
//     for (final argument in arguments.whereType<NamedExpression>()) {
//       if (argument.name.label.name == 'alignment') {
//         hasAlignmentArgument = true;
//         if (argument.expression.computeConstantValue()?.value ==
//             alignmentCenterConstantValue) {
//           return _PreferCenterOverAlignData(
//             isAlignmentCenter: true,
//             alignmentExpression: argument,
//             listOfArguments: arguments,
//           );
//         }
//       }
//     }
//     if (!hasAlignmentArgument) {
//       return _PreferCenterOverAlignData(isAlignmentCenter: true);
//     }
//     return null;
//   }
// }
//
// class _PreferCenterOverAlignData {
//   _PreferCenterOverAlignData({
//     required this.isAlignmentCenter,
//     this.alignmentExpression,
//     this.listOfArguments,
//   });
//
//   final bool isAlignmentCenter;
//   final Expression? alignmentExpression;
//   final NodeList<Expression>? listOfArguments;
// }
//
// class _PreferCenterOverAlignFix extends DartFix {
//   @override
//   void run(
//     CustomLintResolver resolver,
//     ChangeReporter reporter,
//     CustomLintContext context,
//     Diagnostic analysisError,
//     List<Diagnostic> errors,
//   ) {
//     if (analysisError.data case final _PreferCenterOverAlignData data) {
//       reporter
//           .createChangeBuilder(message: 'Replace with Center', priority: 1)
//           .addDartFileEdit((builder) {
//             builder.addSimpleReplacement(analysisError.sourceRange, 'Center');
//             if (data case _PreferCenterOverAlignData(
//               :final listOfArguments?,
//               :final alignmentExpression?,
//             )) {
//               builder.addDeletion(
//                 range.nodeInList(listOfArguments, alignmentExpression),
//               );
//             }
//           });
//     }
//   }
// }
