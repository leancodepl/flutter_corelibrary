import 'package:analyzer_testing/analysis_rule/analysis_rule.dart';
import 'package:leancode_lint/lints/use_padding.dart';
import 'package:test_reflective_loader/test_reflective_loader.dart';

import '../assert_ranges.dart';
import '../mock_libraries.dart';

void main() {
  defineReflectiveSuite(() {
    defineReflectiveTests(UsePaddingTest);
  });
}

@reflectiveTest
class UsePaddingTest extends AnalysisRuleTest {
  @override
  void setUp() {
    rule = UsePadding();
    addMocks([.flutter]);

    super.setUp();
  }

  Future<void> test_container_with_margin_flagged() async {
    await assertDiagnosticsInRanges('''
import 'package:flutter/material.dart';

void test() {
  [!Container!](
    margin: const EdgeInsets.all(10),
    child: const SizedBox(),
  );
}
''');
  }

  Future<void> test_container_with_margin_and_key_flagged() async {
    await assertDiagnosticsInRanges('''
import 'package:flutter/material.dart';

void test() {
  [!Container!](
    margin: const EdgeInsets.all(10),
    key: const Key('key'),
    child: const SizedBox(),
  );
}
''');
  }

  Future<void> test_container_with_margin_and_color_ignored() async {
    await assertNoDiagnostics('''
import 'package:flutter/material.dart';

void test() {
  Container(
    margin: const EdgeInsets.all(10),
    color: Colors.red,
    child: const SizedBox(),
  );
}
''');
  }

  Future<void> test_container_without_margin_ignored() async {
    await assertNoDiagnostics('''
import 'package:flutter/material.dart';

void test() {
  Container(
    color: Colors.red,
    child: const SizedBox(),
  );
}
''');
  }

  Future<void> test_container_with_margin_and_no_child_flagged() async {
    await assertDiagnosticsInRanges('''
import 'package:flutter/material.dart';

void test() {
  [!Container!](
    margin: const EdgeInsets.all(10),
  );
}
''');
  }

  Future<void> test_padding_widget_ignored() async {
    await assertNoDiagnostics('''
import 'package:flutter/material.dart';

void test() {
  const Padding(
    padding: EdgeInsets.all(10),
    child: SizedBox(),
  );
}
''');
  }

  Future<void> test_container_with_null_margin_ignored() async {
    await assertNoDiagnostics('''
import 'package:flutter/material.dart';

void test() {
  Container(
    margin: null,
    child: const SizedBox(),
  );
}
''');
  }

  Future<void> test_container_with_nullable_margin_ignored() async {
    await assertNoDiagnostics('''
import 'package:flutter/material.dart';

void test() {
  const EdgeInsets? nullablePadding = null;
  Container(
    margin: nullablePadding,
    child: const SizedBox(),
  );
}
''');
  }
}
