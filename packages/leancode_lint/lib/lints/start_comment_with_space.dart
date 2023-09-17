import 'package:analyzer/dart/ast/token.dart';
import 'package:analyzer/error/error.dart';
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';
import 'package:leancode_lint/helpers.dart';

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
    return [_AddStartingSpaceToComment()];
  }

  @override
  void run(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
  ) {
    context.registry.addRegularComment((token) {
      if (_commentErrorOffset(token) case final contentStart?) {
        reporter.reportErrorForOffset(
          _createCode(_CommentType.comment),
          token.offset + contentStart,
          0,
        );
      }
    });

    context.registry.addComment((node) {
      for (final token in node.tokens) {
        if (_commentErrorOffset(token) case final contentStart?) {
          reporter.reportErrorForOffset(
            _createCode(_CommentType.doc),
            token.offset + contentStart,
            0,
          );
        }
      }
    });
  }

  int? _commentErrorOffset(Token comment) {
    final lexeme = comment.lexeme;

    // find index of first char after `/`
    var contentStart = 0;
    while (lexeme.length > contentStart && lexeme[contentStart] == '/') {
      contentStart += 1;
    }

    final needsSpace =
        lexeme.length != contentStart && lexeme[contentStart] != ' ';

    if (needsSpace) {
      return contentStart;
    }
    return null;
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
