import 'package:analyzer/src/lint/registry.dart';
import 'package:analyzer_testing/analysis_rule/analysis_rule.dart';
import 'package:leancode_lint/lints/use_padding.dart';
import 'package:test_reflective_loader/test_reflective_loader.dart';

import 'mock_libraries.dart';

void main() {
  defineReflectiveSuite(() {
    defineReflectiveTests(UsePaddingTest);
  });
}

@reflectiveTest
class UsePaddingTest extends AnalysisRuleTest {
  final rule = UsePadding();

  @override
  void setUp() {
    Registry.ruleRegistry.registerWarningRule(rule);
    super.setUp();

    addMocks([MockLibrary.flutter]);
  }

  @override
  String get analysisRule => rule.name;

  Future<void> test_main() async {
    await assertDiagnostics(
      '''
import 'package:flutter/material.dart';

void test() {
  Container(
    margin: const EdgeInsets.all(10),
    child: const SizedBox(),
  );

  Container(
    margin: const EdgeInsets.all(10),
    child: const SizedBox(),
  );

  Container(
    margin: const EdgeInsets.all(10),
    key: const Key('key'),
    child: const SizedBox(),
  );

  Container(
    margin: const EdgeInsets.all(10),
    color: Colors.red,
    child: const SizedBox(),
  );

  Container(
    color: Colors.red,
    child: const SizedBox(),
  );

  Container(
    margin: const EdgeInsets.all(10),
  );

  const Padding(
    padding: EdgeInsets.all(10),
    child: SizedBox(),
  );

  Container(
    margin: null,
    child: const SizedBox(),
  );

  const EdgeInsets? nullablePadding = null;
  Container(
    margin: nullablePadding,
    child: const SizedBox(),
  );
}
''',
      [lint(57, 9), lint(143, 9), lint(229, 9), lint(522, 9)],
    );
  }
}
