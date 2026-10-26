import 'package:analyzer_testing/analysis_rule/analysis_rule.dart';
import 'package:leancode_lint/src/lints/localized_semantics_label.dart';
import 'package:test_reflective_loader/test_reflective_loader.dart';

import '../assert_ranges.dart';
import '../mock_libraries.dart';

void main() {
  defineReflectiveSuite(() {
    defineReflectiveTests(LocalizedSemanticsLabelTest);
  });
}

@reflectiveTest
class LocalizedSemanticsLabelTest() extends AnalysisRuleTest with MockFlutter {
  @override
  void setUp() {
    rule = LocalizedSemanticsLabel();

    super.setUp();
  }

  Future<void> test_text_semantics_label_literal_flagged() async {
    await assertDiagnosticsInRanges('''
import 'package:flutter/widgets.dart';

Widget test() => Text('/', semanticsLabel: [!'BreadCrumbSeparator'!]);
''');
  }

  Future<void> test_icon_semantic_label_literal_flagged() async {
    await assertDiagnosticsInRanges('''
import 'package:flutter/widgets.dart';

Widget test(IconData icon) => Icon(icon, semanticLabel: [!'Close'!]);
''');
  }

  Future<void> test_custom_widget_semantics_label_literal_flagged() async {
    await assertDiagnosticsInRanges('''
class AppIcon {
  const AppIcon({String? semanticsLabel});
}

final icon = AppIcon(semanticsLabel: [!'Close'!]);
''');
  }

  Future<void> test_semantics_text_parameters_flagged() async {
    await assertDiagnosticsInRanges('''
import 'package:flutter/widgets.dart';

Widget test() => Semantics(
  label: /*[0*/'Cart'/*0]*/,
  value: /*[1*/'3 items'/*1]*/,
  hint: /*[2*/'Opens the cart'/*2]*/,
  onTapHint: /*[3*/'open'/*3]*/,
);
''');
  }

  Future<void> test_semantics_properties_and_actions_flagged() async {
    await assertDiagnosticsInRanges('''
import 'package:flutter/widgets.dart';

final properties = SemanticsProperties(label: /*[0*/'Cart'/*0]*/);
final overrides = SemanticsHintOverrides(onLongPressHint: /*[1*/'remove'/*1]*/);
final action = CustomSemanticsAction(label: /*[2*/'Archive'/*2]*/);
''');
  }

  Future<void> test_interpolation_with_text_flagged() async {
    await assertDiagnosticsInRanges(r'''
import 'package:flutter/widgets.dart';

Widget test(int count) => Text('$count', semanticsLabel: [!'$count items'!]);
''');
  }

  Future<void> test_adjacent_strings_flagged() async {
    await assertDiagnosticsInRanges('''
import 'package:flutter/widgets.dart';

Widget test() => Text('', semanticsLabel: [!'Shopping ' 'cart'!]);
''');
  }

  Future<void> test_conditional_and_if_null_branches_flagged() async {
    await assertDiagnosticsInRanges('''
import 'package:flutter/widgets.dart';

Widget test(bool on, String? label) => Column(
  children: [
    Text('', semanticsLabel: on ? /*[0*/'On'/*0]*/ : label),
    Text('', semanticsLabel: label ?? /*[1*/'Unknown'/*1]*/),
  ],
);
''');
  }

  Future<void> test_localized_label_ignored() async {
    await assertNoDiagnostics('''
import 'package:flutter/widgets.dart';

abstract class L10n {
  String get close;
}

Widget test(L10n l10n, IconData icon) => Semantics(
  label: l10n.close,
  child: Icon(icon, semanticLabel: l10n.close),
);
''');
  }

  Future<void> test_interpolation_without_text_ignored() async {
    await assertNoDiagnostics(r'''
import 'package:flutter/widgets.dart';

Widget test(String price, int amount) =>
    Text('', semanticsLabel: '$price: $amount');
''');
  }

  Future<void> test_empty_and_number_literals_ignored() async {
    await assertNoDiagnostics('''
import 'package:flutter/widgets.dart';

Widget test() => Column(
  children: [
    Text('', semanticsLabel: ''),
    Text('', semanticsLabel: '42'),
  ],
);
''');
  }

  Future<void> test_label_of_other_widgets_ignored() async {
    await assertNoDiagnostics('''
class Chip {
  const Chip({String? label});
}

final chip = Chip(label: 'Cart');
''');
  }
}
