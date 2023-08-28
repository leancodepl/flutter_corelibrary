import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';
import 'package:leancode_lint/custom_quick_fixes/add_starting_space_to_comment.dart';

/// Forces comments/docs to start with a space.
class StartCommentWithSpace extends DartLintRule {
  StartCommentWithSpace() : super(code: _createCode(_CommentType.comment));

  static const ruleName = 'start_comment_with_space';

  static LintCode _createCode(_CommentType param) => LintCode(
        name: ruleName,
        problemMessage: 'Start ${param.name}s with a space.',
      );

  @override
  List<Fix> getFixes() {
    return [AddStartingSpaceToComment()];
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
