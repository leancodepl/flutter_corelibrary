import 'package:_fe_analyzer_shared/src/scanner/token.dart';
import 'package:analysis_server_plugin/edit/dart/correction_producer.dart';
import 'package:analysis_server_plugin/edit/dart/dart_fix_kind_priority.dart';
import 'package:analysis_server_plugin/src/correction/fix_generators.dart';
import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/error/error.dart';
import 'package:analyzer_plugin/utilities/change_builder/change_builder_core.dart';
import 'package:analyzer_plugin/utilities/fixes/fixes.dart';
import 'package:leancode_lint/helpers.dart';

/// Forces comments/docs to start with a space.
class StartCommentsWithSpace extends AnalysisRule with AnalysisRuleWithFixes {
  StartCommentsWithSpace()
    : super(
        name: 'start_comments_with_space',
        description: 'Start {0} with a space.',
      );

  @override
  LintCode get diagnosticCode => LintCode(name, description);

  @override
  List<ProducerGenerator> get fixes => [AddStartingSpaceToComment.new];

  @override
  void registerNodeProcessors(
    RuleVisitorRegistry registry,
    RuleContext context,
  ) {
    registry
      ..addRegularComment(this, _visitCommentToken)
      ..addComment(this, _Visitor(this, context));
  }

  void _visitCommentToken(Token token) {
    if (_commentErrorOffset(token) case final contentStart?) {
      reportAtOffset(
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

class _Visitor extends SimpleAstVisitor<void> {
  _Visitor(this.rule, this.context);

  final StartCommentsWithSpace rule;
  final RuleContext context;

  @override
  void visitComment(Comment node) {
    node.tokens.forEach(rule._visitCommentToken);
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

enum _CommentType {
  comment('comments'),
  doc('doc comments');

  const _CommentType(this.pluralName);

  final String pluralName;
}

class AddStartingSpaceToComment extends ResolvedCorrectionProducer {
  AddStartingSpaceToComment({required super.context});

  @override
  FixKind? get fixKind => const FixKind(
    'leancode.lint.addStartingSpaceToComment',
    DartFixKindPriority.standard,
    'Add leading space to comment',
  );

  @override
  CorrectionApplicability get applicability =>
      CorrectionApplicability.singleLocation;

  @override
  Future<void> compute(ChangeBuilder builder) async {
    await builder.addDartFileEdit(
      file,
      (builder) => builder.addSimpleInsertion(diagnosticOffset!, ' '),
    );
  }
}
