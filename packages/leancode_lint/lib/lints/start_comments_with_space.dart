import 'package:analyzer/dart/ast/token.dart';
import 'package:analyzer/diagnostic/diagnostic.dart';
import 'package:analyzer/error/error.dart' hide LintCode;
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';
import 'package:leancode_lint/helpers.dart';

/// Forces comments/docs to start with a space.
class StartCommentsWithSpace extends DartLintRule {
  const StartCommentsWithSpace()
    : super(
        code: const LintCode(
          name: 'start_comments_with_space',
          problemMessage: 'Start {0} with a space.',
          errorSeverity: DiagnosticSeverity.WARNING,
        ),
      );

  @override
  List<Fix> getFixes() {
    return [_AddStartingSpaceToComment()];
  }

  @override
  void run(
    CustomLintResolver resolver,
    DiagnosticReporter reporter,
    CustomLintContext context,
  ) {
    context.registry.addRegularComment((token) {
      if (_commentErrorOffset(token) case final contentStart?) {
        reporter.atOffset(
          offset: token.offset + contentStart,
          length: 0,
          diagnosticCode: code,
          arguments: [_CommentType.comment.pluralName],
        );
      }
    });

    context.registry.addComment((node) {
      for (final token in node.tokens) {
        if (_commentErrorOffset(token) case final contentStart?) {
          reporter.atOffset(
            offset: token.offset + contentStart,
            length: 0,
            diagnosticCode: code,
            arguments: [_CommentType.doc.pluralName],
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
    Diagnostic analysisError,
    List<Diagnostic> others,
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
