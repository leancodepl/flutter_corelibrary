import 'package:analyzer_testing/analysis_rule/analysis_rule.dart';
import 'package:leancode_lint/src/lints/avoid_catch_error.dart';
import 'package:test_reflective_loader/test_reflective_loader.dart';

import '../assert_ranges.dart';

void main() {
  defineReflectiveSuite(() {
    defineReflectiveTests(AvoidCatchErrorTest);
  });
}

@reflectiveTest
class AvoidCatchErrorTest extends AnalysisRuleTest {
  @override
  void setUp() {
    rule = AvoidCatchError();

    super.setUp();
  }

  Future<void> test_future_catch_error_is_marked() async {
    await assertDiagnosticsInRanges('''
import 'dart:async';

Future<void> doSomething() async {}

Future<void> test(Future<void> future) {
  return future.[!catchError!]((Object err, StackTrace st) {
    return doSomething();
  });
}
''');
  }

  Future<void> test_future_catch_error_cascade_is_marked() async {
    await assertDiagnosticsInRanges('''
import 'dart:async';

Future<void> test(Future<void> future) async {
  future..[!catchError!]((Object err, StackTrace st) {});
}
''');
  }

  Future<void> test_catch_error_does_not_catch_synchronous_throw() async {
    await assertDiagnosticsInRanges(r'''
import 'dart:async';

Future<void> syncThrowing() {
  throw 'sync';
}

Future<void> asyncThrowing() async {
  throw 'async';
}

Future<void> main() async {
  try {
    await asyncThrowing()./*[0*/catchError/*0]*/((e) => print('Caught $e'));
    await syncThrowing()./*[1*/catchError/*1]*/((e) => print('Caught $e'));
  } catch (e) {
    print('Uncaught $e');
  }
}
''');
  }

  Future<void> test_try_catch_is_not_marked() async {
    await assertNoDiagnostics('''
import 'dart:async';

Future<void> test(Future<void> future) async {
  try {
    await future;
  } catch (err, st) {
    print(st);
    throw err;
  }
}
''');
  }

  Future<void> test_custom_method_named_catch_error_is_not_marked() async {
    await assertNoDiagnostics('''
class HasCatchError {
  void catchError(void Function() onError) {}
}

void test(HasCatchError value) {
  value.catchError(() {});
}
''');
  }
}
