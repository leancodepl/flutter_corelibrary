import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/error/error.dart' as error;
import 'package:analyzer/error/listener.dart';
import 'package:analyzer_plugin/utilities/range_factory.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';
import 'package:leancode_lint/helpers.dart';

class PreferCenterOverAlign extends DartLintRule {
  const PreferCenterOverAlign()
    : super(
        code: const LintCode(
          name: 'prefer_center_over_align',
          problemMessage:
              'Use the Center widget instead of the Align widget with the alignment parameter set to Alignment.center',
        ),
      );

  @override
  List<Fix> getFixes() => [_PreferCenterOverAlignFix()];

  @override
  void run(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
  ) {
    context.registry.addInstanceCreationExpression((node) {
      final data = _analyzeAlignInstanceCreationExpression(node);
      if (data case final data? when data.isAlignmentCenter) {
        reporter.atNode(node.constructorName, code, data: data);
      }
    });
  }

  _PreferCenterOverAlignData? _analyzeAlignInstanceCreationExpression(
    InstanceCreationExpression node,
  ) {
    if (!isExpressionExactlyType(node, 'Align', 'flutter')) {
      return null;
    }
    final arguments = node.argumentList.arguments;
    var hasAlignmentArgument = false;

    for (final argument in arguments.whereType<NamedExpression>()) {
      if (_isArgumentNameAlignment(argument)) {
        hasAlignmentArgument = true;
        if (_isValueAlignmentCenter(argument)) {
          return _PreferCenterOverAlignData(
            isAlignmentCenter: true,
            alignmentExpression: argument,
            listOfArguments: arguments,
          );
        }
      }
    }
    if (!hasAlignmentArgument) {
      return _PreferCenterOverAlignData(isAlignmentCenter: true);
    }
    return null;
  }

  bool _isArgumentNameAlignment(NamedExpression argument) =>
      argument.name.label.name == 'alignment';

  bool _isValueAlignmentCenter(NamedExpression argument) {
    if (argument.expression case PrefixedIdentifier(name: 'Alignment.center')) {
      return true;
    } else if (argument.expression case InstanceCreationExpression(
      staticType: final type,
      argumentList: ArgumentList(:final arguments),
    ) when type?.getDisplayString() == 'Alignment') {
      if (arguments.length == 2 &&
          arguments.every(
            (argument) => switch (argument) {
              IntegerLiteral(value: final value) when value == 0 => true,
              DoubleLiteral(value: final value) when value == 0.0 => true,
              _ => false,
            },
          )) {
        return true;
      }
    }
    return false;
  }
}

class _PreferCenterOverAlignData {
  _PreferCenterOverAlignData({
    required this.isAlignmentCenter,
    this.alignmentExpression,
    this.listOfArguments,
  });

  final bool isAlignmentCenter;
  final Expression? alignmentExpression;
  final NodeList<Expression>? listOfArguments;
}

class _PreferCenterOverAlignFix extends DartFix {
  @override
  void run(
    CustomLintResolver resolver,
    ChangeReporter reporter,
    CustomLintContext context,
    error.AnalysisError analysisError,
    List<error.AnalysisError> errors,
  ) {
    if (analysisError.data case final _PreferCenterOverAlignData data) {
      reporter
          .createChangeBuilder(message: 'Replace with Center', priority: 1)
          .addDartFileEdit((builder) {
            builder.addSimpleReplacement(analysisError.sourceRange, 'Center');
            if (data case _PreferCenterOverAlignData(
              :final listOfArguments?,
              :final alignmentExpression?,
            )) {
              builder.addDeletion(
                range.nodeInList(listOfArguments, alignmentExpression),
              );
            }
          });
    }
  }
}
