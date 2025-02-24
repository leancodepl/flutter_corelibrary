import 'package:_fe_analyzer_shared/src/scanner/token.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/token.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/error/error.dart';
import 'package:analyzer/error/listener.dart';
import 'package:analyzer/src/lint/linter.dart';
import 'package:leancode_lint/helpers.dart';

/// Forces comments/docs to start with a space.
class StartCommentsWithSpace extends AnalysisRule {
  StartCommentsWithSpace()
    : super(
        name: 'start_comments_with_space',
        description: 'Start {0} with a space.',
      );

  @override
  LintCode get lintCode => LintCode(name, description);

  @override
  List<Fix> getFixes() {
    return [_AddStartingSpaceToComment()];
  }

  @override
  void registerNodeProcessors(
    NodeLintRegistry registry,
    LinterContext context,
  ) {
    registry.addComment(this, _Visitor(this, context));
  }
}

class _Visitor extends SimpleAstVisitor<void> {
  _Visitor(this.rule, this.context);

  final LintRule rule;
  final LinterContext context;

  @override
  void visitComment(Comment node) {
    for (final token in node.tokens) {
      if (_commentErrorOffset(token) case final contentStart?) {
        rule.reportLintForOffset(
          token.offset + contentStart,
          0,
          arguments: [
            if (token is DocumentationCommentToken)
              _CommentType.doc.pluralName
            else
              _CommentType.comment.pluralName,
          ],
        );
      }
    }
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
  comment('comments'),
  doc('doc comments');

  const _CommentType(this.pluralName);

  final String pluralName;
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
