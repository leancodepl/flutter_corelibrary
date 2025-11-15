import 'package:analyzer_testing/analysis_rule/analysis_rule.dart';
import 'package:leancode_lint/lints/catch_parameter_names.dart';
import 'package:test_reflective_loader/test_reflective_loader.dart';

void main() {
  defineReflectiveSuite(() {
    defineReflectiveTests(CatchParameterNamesTest);
  });
}

@reflectiveTest
class CatchParameterNamesTest extends AnalysisRuleTest {
  @override
  void setUp() {
    rule = CatchParameterNames();
    super.setUp();
  }

  Future<void> test_main() async {
    await assertDiagnostics(
      '''
Object? someFunction() {
  try {} catch (exception) {
    return exception;
  }

  try {} catch (err, stackTrace) {
    return stackTrace;
  }

  try {} on Exception catch (err, stackTrace) {
    return stackTrace;
  }

  try {} on Exception catch (exception, st) {
    return st;
  }

  try {} catch (err, st) {
    return st;
  }

  return null;
}
''',
      [lint(41, 9), lint(102, 10), lint(178, 10)],
    );
  }
}
