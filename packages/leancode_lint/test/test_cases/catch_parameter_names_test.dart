import 'package:analyzer_testing/analysis_rule/analysis_rule.dart';
import 'package:leancode_lint/lints/catch_parameter_names.dart';
import 'package:test_reflective_loader/test_reflective_loader.dart';

import '../assert_ranges.dart';

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
    await assertDiagnosticsInRanges('''
Object? someFunction() {
  try {} catch (/*[0*/exception/*0]*/) {
    return exception;
  }

  try {} catch (err, /*[1*/stackTrace/*1]*/) {
    return stackTrace;
  }

  try {} on Exception catch (err, /*[2*/stackTrace/*2]*/) {
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
''');
  }
}
