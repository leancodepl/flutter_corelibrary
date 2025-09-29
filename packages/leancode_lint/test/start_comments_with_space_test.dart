import 'package:analyzer/src/lint/registry.dart';
import 'package:analyzer_testing/analysis_rule/analysis_rule.dart';
import 'package:leancode_lint/lints/start_comments_with_space.dart';
import 'package:test_reflective_loader/test_reflective_loader.dart';

void main() {
  defineReflectiveSuite(() {
    defineReflectiveTests(StartCommentsWithSpaceTest);
  });
}

@reflectiveTest
class StartCommentsWithSpaceTest extends AnalysisRuleTest {
  final rule = StartCommentsWithSpace();

  @override
  void setUp() {
    Registry.ruleRegistry.registerWarningRule(rule);
    super.setUp();
  }

  @override
  String get analysisRule => rule.name;

  Future<void> test_main() async {
    await assertDiagnostics(
      '''
///Invalid docs comment
const a = 'abc';

/// Valid docs comment
const b = 'def';

//Invalid comment
const c = 'ghi';

// Valid comment
const d = 'jkl';
''',
      [lint(3, 0), lint(85, 0)],
    );
  }
}
