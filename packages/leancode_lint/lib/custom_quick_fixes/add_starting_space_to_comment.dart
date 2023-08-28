import 'package:analyzer/error/error.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

class AddStartingSpaceToComment extends DartFix {
  @override
  void run(
    CustomLintResolver resolver,
    ChangeReporter reporter,
    CustomLintContext context,
    AnalysisError analysisError,
    List<AnalysisError> others,
  ) {
    reporter
        .createChangeBuilder(
          message: 'Add leading space to comment',
          priority: 1,
        )
        .addDartFileEdit(
          (builder) => builder.addSimpleInsertion(analysisError.offset, ' '),
        );
  }
}
