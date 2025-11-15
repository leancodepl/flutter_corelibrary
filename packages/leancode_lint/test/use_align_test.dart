import 'package:analyzer_testing/analysis_rule/analysis_rule.dart';
import 'package:leancode_lint/lints/use_align.dart';
import 'package:test_reflective_loader/test_reflective_loader.dart';

import 'mock_libraries.dart';

void main() {
  defineReflectiveSuite(() {
    defineReflectiveTests(UseAlignTest);
  });
}

@reflectiveTest
class UseAlignTest extends AnalysisRuleTest {
  @override
  void setUp() {
    rule = UseAlign();
    super.setUp();

    addMocks([MockLibrary.flutter]);
  }

  Future<void> test_container_with_only_align() async {
    await assertDiagnostics(
      '''
import 'package:flutter/material.dart';

void test () {
  Container(
    alignment: Alignment.center,
    child: const SizedBox(),
  );

  Container(
    alignment: Alignment.centerLeft,
    child: const SizedBox(),
  );

  Container(
    key: const Key('key'),
    alignment: Alignment.topCenter,
    child: const SizedBox(),
  );

  Container(
    alignment: Alignment.center,
  );
}
''',
      [lint(58, 9), lint(139, 9), lint(224, 9), lint(335, 9)],
    );
  }

  Future<void> test_container_with_other_properties() async {
    await assertNoDiagnostics('''
import 'package:flutter/material.dart';

void test () {
  Container(
    alignment: Alignment.center,
    color: Colors.red,
    child: const SizedBox(),
  );

  Container(
    color: Colors.red,
    child: const SizedBox(),
  );
}
''');
  }

  Future<void> test_align_widget_not_flagged() async {
    await assertNoDiagnostics('''
import 'package:flutter/material.dart';

void test () {
  const Align(
    alignment: Alignment.bottomCenter,
    child: SizedBox(),
  );
}
''');
  }

  Future<void> test_container_with_nullable_alignment() async {
    await assertNoDiagnostics('''
import 'package:flutter/material.dart';

void test() {
  Container(
    alignment: null,
    child: const SizedBox(),
  );

  const AlignmentGeometry? nullableAlignment = null;

  Container(
    alignment: nullableAlignment,
    child: const SizedBox(),
  );
}
''');
  }
}
