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
    defineReflectiveTests(UseDesignSystemItemColorTest);
    defineReflectiveTests(UseDesignSystemItemStaticMembersTest);
  });
}

@reflectiveTest
class UseDesignSystemItemTextTest() extends AnalysisRuleTest with MockFlutter {
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

  Future<void> test_text_dot_shorthand_new_flagged() async {
    await assertDiagnosticsInRanges('''
import 'package:flutter/material.dart';

void test() {
  const /*[0*/Text/*0]*/ text = ./*[1*/new/*1]*/('abc');
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
class UseDesignSystemItemScaffoldTest()
    extends AnalysisRuleTest
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
class UseDesignSystemItemWithSpacesTest()
    extends AnalysisRuleTest
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

@reflectiveTest
class UseDesignSystemItemColorTest() extends AnalysisRuleTest with MockFlutter {
  @override
  void setUp() {
    rule = UseDesignSystemItem.fromConfig(
      const .new(
        designSystemItemReplacements: {
          'AppColor': [.new(name: 'Color', packageName: 'dart:ui')],
        },
      ),
    ).single;

    super.setUp();
  }

  Future<void> test_explicit_constructor_flagged() async {
    await assertDiagnosticsInRanges('''
import 'package:flutter/material.dart';

Widget test() => Container(color: const [!Color!](0xFF00FF00));
''');
  }

  Future<void> test_dot_shorthand_new_flagged() async {
    await assertDiagnosticsInRanges('''
import 'package:flutter/material.dart';

Widget test() => Container(color: const .[!new!](0xFF00FF00));
''');
  }

  Future<void> test_dot_shorthand_named_constructor_flagged() async {
    await assertDiagnosticsInRanges('''
import 'package:flutter/material.dart';

Widget test() => Container(color: const .[!fromARGB!](255, 0, 255, 0));
''');
  }

  Future<void> test_non_const_dot_shorthand_named_constructor_flagged() async {
    await assertDiagnosticsInRanges('''
import 'package:flutter/material.dart';

Widget test(int a) => Container(color: .[!fromARGB!](a, 0, 255, 0));
''');
  }

  Future<void> test_dot_shorthand_for_other_type_not_flagged() async {
    await assertNoDiagnostics('''
import 'package:flutter/material.dart';

Widget test() => const Text('abc', textAlign: .center);
''');
  }
}

@reflectiveTest
class UseDesignSystemItemStaticMembersTest() extends AnalysisRuleTest {
  @override
  void setUp() {
    rule = UseDesignSystemItem.fromConfig(
      const .new(
        designSystemItemReplacements: {
          'AppSpacing': [.new(name: 'Spacing', packageName: 'test')],
        },
      ),
    ).single;

    super.setUp();
  }

  Future<void> test_dot_shorthand_static_members_flagged() async {
    await assertDiagnosticsInRanges('''
// ignore: use_design_system_item_AppSpacing
class Spacing {
  // ignore: use_design_system_item_AppSpacing
  const Spacing._();

  // ignore: use_design_system_item_AppSpacing
  static const Spacing small = ._();

  // ignore: use_design_system_item_AppSpacing
  static Spacing of(int value) => small;
}

void test() {
  /*[0*/Spacing/*0]*/ a = ./*[1*/small/*1]*/;
  a = ./*[2*/of/*2]*/(1);
}
''');
  }
}
