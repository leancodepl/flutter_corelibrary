import 'package:analyzer_testing/analysis_rule/analysis_rule.dart';
import 'package:leancode_lint/lints/start_comments_with_space.dart';
import 'package:test_reflective_loader/test_reflective_loader.dart';

import '../assert_ranges.dart';

void main() {
  defineReflectiveSuite(() {
    defineReflectiveTests(StartCommentsWithSpaceTest);
  });
}

@reflectiveTest
class StartCommentsWithSpaceTest extends AnalysisRuleTest {
  @override
  void setUp() {
    rule = StartCommentsWithSpace();
    super.setUp();
  }

  Future<void> test_main() async {
    await assertDiagnosticsInRanges('''
////*0*/Invalid docs comment
const a = 'abc';

/// Valid docs comment
const b = 'def';

///*1*/Invalid comment
const c = 'ghi';

// Valid comment
const d = 'jkl';
''');
  }
}
