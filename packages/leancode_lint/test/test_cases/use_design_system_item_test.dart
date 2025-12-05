import 'package:analyzer_testing/analysis_rule/analysis_rule.dart';
import 'package:leancode_lint/lints/use_design_system_item.dart';
import 'package:test_reflective_loader/test_reflective_loader.dart';

import '../assert_ranges.dart';
import '../mock_libraries.dart';

void main() {
  defineReflectiveSuite(() {
    defineReflectiveTests(UseDesignSystemItemTest);
  });
}

@reflectiveTest
class UseDesignSystemItemTest extends AnalysisRuleTest {
  @override
  void setUp() {
    rule = UseDesignSystemItem();
    super.setUp();

    addMocks([.flutter]);
    addAnalysisOptions();
  }

  Future<void> test_text_variable_declaration_flagged() async {
    await assertDiagnosticsInRanges('''
import 'package:flutter/material.dart';

void test() {
  [!Text?!] text;
}
''');
  }

  Future<void> test_scaffold_flagged() async {
    await assertDiagnosticsInRanges('''
import 'package:flutter/material.dart';

void test() {
  [!Scaffold!](
    body: SizedBox(),
  );
}
''');
  }

  Future<void> test_text_in_appbar_title_flagged() async {
    await assertDiagnosticsInRanges('''
import 'package:flutter/material.dart';

void test() {
  /*[0*/Scaffold/*0]*/(
    appBar: AppBar(
      title: const /*[1*/Text/*1]*/('abc'),
    ),
  );
}
''');
  }

  Future<void> test_richtext_with_textspan_flagged() async {
    await assertDiagnosticsInRanges('''
import 'package:flutter/material.dart';

void test() {
  [!RichText!](text: const TextSpan(text: 'abc'));
}
''');
  }

  Future<void> test_hide_combinator_ignored() async {
    await assertNoDiagnostics('''
import 'package:flutter/material.dart'
    hide Text;

void test() {
  const SizedBox();
}
''');
  }
}
