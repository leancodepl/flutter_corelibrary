import 'package:analyzer_testing/analysis_rule/analysis_rule.dart';
import 'package:leancode_lint/src/lints/on_tap_hint_requires_hint.dart';
import 'package:test_reflective_loader/test_reflective_loader.dart';

import '../assert_ranges.dart';
import '../mock_libraries.dart';

void main() {
  defineReflectiveSuite(() {
    defineReflectiveTests(OnTapHintRequiresHintTest);
  });
}

@reflectiveTest
class OnTapHintRequiresHintTest() extends AnalysisRuleTest with MockFlutter {
  @override
  void setUp() {
    rule = OnTapHintRequiresHint();

    super.setUp();
  }

  Future<void> test_on_tap_hint_without_hint_flagged() async {
    await assertDiagnosticsInRanges(
      '''
import 'package:flutter/widgets.dart';

Widget test(String open) => Semantics([!onTapHint!]: open, onTap: () {});
''',
      messageContainsAll: [
        ["'onTapHint' is ignored on iOS"],
      ],
    );
  }

  Future<void> test_both_hint_overrides_without_hint_flagged() async {
    await assertDiagnosticsInRanges('''
import 'package:flutter/widgets.dart';

Widget test(String open, String remove) =>
    Semantics(/*[0*/onTapHint/*0]*/: open, /*[1*/onLongPressHint/*1]*/: remove);
''');
  }

  Future<void> test_on_tap_hint_with_null_hint_flagged() async {
    await assertDiagnosticsInRanges('''
import 'package:flutter/widgets.dart';

Widget test(String open) => Semantics(hint: null, [!onTapHint!]: open);
''');
  }

  Future<void> test_semantics_properties_hint_overrides_flagged() async {
    await assertDiagnosticsInRanges('''
import 'package:flutter/widgets.dart';

Widget test(String open) => Semantics.fromProperties(
  properties: SemanticsProperties(
    [!hintOverrides!]: SemanticsHintOverrides(onTapHint: open),
  ),
);
''');
  }

  Future<void> test_on_tap_hint_with_hint_ignored() async {
    await assertNoDiagnostics('''
import 'package:flutter/widgets.dart';

Widget test(String open, bool isIOS) =>
    Semantics(hint: isIOS ? open : null, onTapHint: open);
''');
  }

  Future<void> test_semantics_properties_with_hint_ignored() async {
    await assertNoDiagnostics('''
import 'package:flutter/widgets.dart';

final properties = SemanticsProperties(
  hint: 'Opens the cart',
  hintOverrides: SemanticsHintOverrides(onTapHint: 'open'),
);
''');
  }

  Future<void> test_null_on_tap_hint_ignored() async {
    await assertNoDiagnostics('''
import 'package:flutter/widgets.dart';

Widget test() => Semantics(onTapHint: null);
''');
  }
}
