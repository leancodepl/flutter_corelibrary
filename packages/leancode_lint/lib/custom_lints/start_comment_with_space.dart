import 'package:analyzer/error/error.dart';
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

/// Forces comments/docs to start with a space.
class StartCommentWithSpace extends DartLintRule {
  StartCommentWithSpace() : super(code: _createCode(_CommentType.comment));

  static LintCode _createCode(_CommentType param) => LintCode(
        name: 'start_comment_with_space',
        problemMessage: 'Start ${param.name}s with a space.',
      );

  @override
  List<Fix> getFixes() {
    return [_AddStartingSpaceToComment()];
  }

  @override
  void run(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
  ) {
    // TODO: this visitor does not visit normal comments, just doc comments
    context.registry.addComment((node) {
      for (final token in node.tokens) {
        final lexeme = token.lexeme;

        // find index of first char after `/`
        var contentStart = 0;
        while (lexeme.length > contentStart && lexeme[contentStart] == '/') {
          contentStart += 1;
        }

        final needsSpace =
            lexeme.length != contentStart && lexeme[contentStart] != ' ';

        if (needsSpace) {
          reporter.reportErrorForOffset(
            _createCode(_CommentType.doc),
            token.offset + contentStart,
            0,
          );
        }
      }
    });
  }
}

enum _CommentType {
  comment,
  doc;
}

class _AddStartingSpaceToComment extends DartFix {
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
