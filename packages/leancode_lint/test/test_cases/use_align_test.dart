import 'package:analyzer_testing/analysis_rule/analysis_rule.dart';
import 'package:leancode_lint/src/lints/use_align.dart';
import 'package:test_reflective_loader/test_reflective_loader.dart';

import '../assert_ranges.dart';
import '../mock_libraries.dart';

void main() {
  defineReflectiveSuite(() {
    defineReflectiveTests(UseAlignTest);
  });
}

@reflectiveTest
class UseAlignTest extends AnalysisRuleTest with MockFlutter {
  @override
  void setUp() {
    rule = UseAlign();

    super.setUp();
  }

  Future<void> test_container_with_only_align() async {
    await assertDiagnosticsInRanges('''
import 'package:flutter/material.dart';

void test () {
  /*[0*/Container/*0]*/(
    alignment: Alignment.center,
    child: const SizedBox(),
  );

  /*[1*/Container/*1]*/(
    alignment: Alignment.centerLeft,
    child: const SizedBox(),
  );

  /*[2*/Container/*2]*/(
    key: const Key('key'),
    alignment: Alignment.topCenter,
    child: const SizedBox(),
  );

  /*[3*/Container/*3]*/(
    alignment: Alignment.center,
  );
}
''');
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
