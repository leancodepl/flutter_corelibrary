import 'package:analyzer_testing/analysis_rule/analysis_rule.dart';
import 'package:leancode_lint/src/lints/icon_only_button_requires_label.dart';
import 'package:test_reflective_loader/test_reflective_loader.dart';

import '../assert_ranges.dart';
import '../mock_libraries.dart';

void main() {
  defineReflectiveSuite(() {
    defineReflectiveTests(IconOnlyButtonRequiresLabelTest);
  });
}

@reflectiveTest
class IconOnlyButtonRequiresLabelTest()
    extends AnalysisRuleTest
    with MockFlutter {
  @override
  void setUp() {
    rule = IconOnlyButtonRequiresLabel();

    super.setUp();
  }

  Future<void> test_icon_button_without_tooltip_flagged() async {
    await assertDiagnosticsInRanges(
      '''
import 'package:flutter/material.dart';

Widget test() => IconButton(
  onPressed: () {},
  icon: const [!Icon!](Icons.book),
);
''',
      messageContainsAll: [
        ["'IconButton'"],
      ],
    );
  }

  Future<void>
  test_icon_button_selected_icon_and_named_constructor_flagged() async {
    await assertDiagnosticsInRanges('''
import 'package:flutter/material.dart';

Widget test() => Column(
  children: [
    IconButton(
      onPressed: () {},
      icon: /*[0*/Icon/*0]*/(Icons.alarm),
      selectedIcon: /*[1*/Icon/*1]*/(Icons.book),
    ),
    IconButton.filled(onPressed: () {}, icon: /*[2*/Icon/*2]*/(Icons.alarm)),
  ],
);
''');
  }

  Future<void> test_fab_without_tooltip_flagged() async {
    await assertDiagnosticsInRanges('''
import 'package:flutter/material.dart';

Widget test() =>
    FloatingActionButton(onPressed: () {}, child: [!Icon!](Icons.alarm));
''');
  }

  Future<void> test_gesture_detector_and_ink_well_flagged() async {
    await assertDiagnosticsInRanges('''
import 'package:flutter/material.dart';

Widget test() => Column(
  children: [
    GestureDetector(onTap: () {}, child: /*[0*/Icon/*0]*/(Icons.alarm)),
    InkWell(onTap: () {}, child: /*[1*/Icon/*1]*/(Icons.alarm)),
    InkResponse(onTap: () {}, child: /*[2*/Icon/*2]*/(Icons.alarm)),
  ],
);
''');
  }

  Future<void> test_icon_with_null_semantic_label_flagged() async {
    await assertDiagnosticsInRanges('''
import 'package:flutter/material.dart';

Widget test() => IconButton(
  onPressed: () {},
  icon: [!Icon!](Icons.book, semanticLabel: null),
);
''');
  }

  Future<void> test_icon_with_semantic_label_ignored() async {
    await assertNoDiagnostics('''
import 'package:flutter/material.dart';

Widget test(String close) => Column(
  children: [
    IconButton(
      onPressed: () {},
      icon: Icon(Icons.book, semanticLabel: close),
    ),
    GestureDetector(
      onTap: () {},
      child: Icon(Icons.book, semanticLabel: close),
    ),
  ],
);
''');
  }

  Future<void> test_tooltip_ignored() async {
    await assertNoDiagnostics('''
import 'package:flutter/material.dart';

Widget test(String close) => Column(
  children: [
    IconButton(onPressed: () {}, tooltip: close, icon: Icon(Icons.book)),
    FloatingActionButton(
      onPressed: () {},
      tooltip: close,
      child: Icon(Icons.book),
    ),
  ],
);
''');
  }

  Future<void> test_labelled_ancestor_ignored() async {
    await assertNoDiagnostics('''
import 'package:flutter/material.dart';

Widget test(String close) => Column(
  children: [
    Semantics(
      label: close,
      button: true,
      child: GestureDetector(onTap: () {}, child: Icon(Icons.book)),
    ),
    Tooltip(
      message: close,
      child: InkWell(onTap: () {}, child: Icon(Icons.book)),
    ),
  ],
);
''');
  }

  Future<void> test_unlabelled_semantics_ancestor_flagged() async {
    await assertDiagnosticsInRanges('''
import 'package:flutter/material.dart';

Widget test() => Semantics(
  button: true,
  child: GestureDetector(onTap: () {}, child: [!Icon!](Icons.book)),
);
''');
  }

  Future<void> test_excluded_from_semantics_ignored() async {
    await assertNoDiagnostics('''
import 'package:flutter/material.dart';

Widget test() => GestureDetector(
  onTap: () {},
  excludeFromSemantics: true,
  child: Icon(Icons.book),
);
''');
  }

  Future<void> test_icon_not_alone_or_outside_tap_targets_ignored() async {
    await assertNoDiagnostics('''
import 'package:flutter/material.dart';

Widget test(String label) => Column(
  children: [
    Icon(Icons.book),
    Row(children: [Icon(Icons.book), Text(label)]),
    GestureDetector(
      onTap: () {},
      child: Row(children: [Icon(Icons.book), Text(label)]),
    ),
    FloatingActionButton.extended(
      onPressed: () {},
      icon: Icon(Icons.alarm),
      label: Text(label),
    ),
  ],
);
''');
  }
}
