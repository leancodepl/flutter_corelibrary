import 'package:analyzer_testing/analysis_rule/analysis_rule.dart';
import 'package:leancode_lint/src/lints/use_design_system_item.dart';
import 'package:test_reflective_loader/test_reflective_loader.dart';

import '../assert_ranges.dart';
import '../mock_libraries.dart';

void main() {
  defineReflectiveSuite(() {
    defineReflectiveTests(UseDesignSystemItemTextTest);
    defineReflectiveTests(UseDesignSystemItemScaffoldTest);
    defineReflectiveTests(UseDesignSystemItemWithSpacesTest);
  });
}

@reflectiveTest
class UseDesignSystemItemTextTest extends AnalysisRuleTest with MockFlutter {
  @override
  void setUp() {
    rule = UseDesignSystemItem.fromConfig(
      const .new(
        designSystemItemReplacements: {
          'LftText': [
            .new(name: 'Text', packageName: 'flutter'),
            .new(name: 'RichText', packageName: 'flutter'),
          ],
        },
      ),
    ).single;

    super.setUp();
  }

  Future<void> test_text_variable_declaration_flagged() async {
    await assertDiagnosticsInRanges('''
import 'package:flutter/material.dart';

void test() {
  [!Text?!] text;
}
''');
  }

  Future<void> test_text_in_appbar_title_flagged() async {
    await assertDiagnosticsInRanges('''
import 'package:flutter/material.dart';

void test() {
  AppBar(
    title: const [!Text!]('abc'),
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

@reflectiveTest
class UseDesignSystemItemScaffoldTest extends AnalysisRuleTest
    with MockFlutter {
  @override
  void setUp() {
    rule = UseDesignSystemItem.fromConfig(
      const .new(
        designSystemItemReplacements: {
          'LftScaffold': [.new(name: 'Scaffold', packageName: 'flutter')],
        },
      ),
    ).single;

    super.setUp();
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
}

@reflectiveTest
class UseDesignSystemItemWithSpacesTest extends AnalysisRuleTest
    with MockFlutter {
  @override
  void setUp() {
    rule = UseDesignSystemItem.fromConfig(
      const .new(
        designSystemItemReplacements: {
          'This or That': [.new(name: 'Container', packageName: 'flutter')],
        },
      ),
    ).single;

    super.setUp();
  }

  Future<void> test_rule_with_spaces() async {
    await assertDiagnostics(
      '''
import 'package:flutter/material.dart';

void test() {
  Container();
} 
  ''',
      [lint(57, 9, name: 'use_design_system_item_this_or_that')],
    );
  }
}
