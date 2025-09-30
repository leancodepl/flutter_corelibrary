import 'package:analyzer/src/lint/registry.dart';
import 'package:analyzer_testing/analysis_rule/analysis_rule.dart';
import 'package:leancode_lint/lints/avoid_single_child_in_multi_child_widget.dart';
import 'package:test_reflective_loader/test_reflective_loader.dart';

import 'mock_libraries.dart';

void main() {
  defineReflectiveSuite(() {
    defineReflectiveTests(AvoidSingleChildInMultiChildWidgetsTest);
  });
}

@reflectiveTest
class AvoidSingleChildInMultiChildWidgetsTest extends AnalysisRuleTest {
  final rule = AvoidSingleChildInMultiChildWidgets();

  @override
  void setUp() {
    Registry.ruleRegistry.registerWarningRule(rule);
    super.setUp();

    addMocks([MockLibrary.flutter, MockLibrary.sliverTools]);
  }

  @override
  String get analysisRule => rule.name;

  @override
  bool get dumpAstOnFailures => false;

  Future<void> test_column_is_marked() async {
    await assertDiagnostics(
      '''
import 'package:flutter/material.dart';

Widget test() {
  return Column(
    children: [Container()],
  );
}
''',
      [lint(66, 6)],
    );
  }

  Future<void> test_row_is_marked() async {
    await assertDiagnostics(
      '''
import 'package:flutter/material.dart';

Widget test() {
  return Row(
    children: [Container()],
  );
}
''',
      [lint(66, 3)],
    );
  }

  Future<void> test_flex_is_marked() async {
    await assertDiagnostics(
      '''
import 'package:flutter/material.dart';

Widget test() {
  return Flex(
    direction: Axis.horizontal,
    children: [Container()],
  );
}
''',
      [lint(66, 4)],
    );
  }

  Future<void> test_wrap_is_marked() async {
    await assertDiagnostics(
      '''
import 'package:flutter/material.dart';

Widget test() {
  return Wrap(
    children: [Container()],
  );
}
''',
      [lint(66, 4)],
    );
  }

  Future<void> test_sliver_child_list_delegate_is_marked() async {
    await assertDiagnostics(
      '''
import 'package:flutter/material.dart';

Widget test() {
  final _ = SliverChildListDelegate(
    [Container()],
  );

  return const SizedBox();
}
''',
      [lint(69, 23)],
    );
  }

  Future<void> test_sliver_list_is_marked() async {
    await assertDiagnostics(
      '''
import 'package:flutter/material.dart';

Widget test() {
  return SliverList.list(
    children: [Container()],
  );
}
''',
      [lint(66, 10)],
    );
  }

  Future<void> test_sliver_main_axis_group_is_marked() async {
    await assertDiagnostics(
      '''
import 'package:flutter/material.dart';

Widget test() {
  return const SliverMainAxisGroup(
    slivers: [SliverToBoxAdapter()],
  );
}
''',
      [lint(72, 19)],
    );
  }

  Future<void> test_sliver_cross_axis_group_is_marked() async {
    await assertDiagnostics(
      '''
import 'package:flutter/material.dart';

Widget test() {
  return const SliverCrossAxisGroup(
    slivers: [SliverToBoxAdapter()],
  );
}
''',
      [lint(72, 20)],
    );
  }

  Future<void> test_multi_sliver_is_marked() async {
    await assertDiagnostics(
      '''
import 'package:flutter/material.dart';
import 'package:sliver_tools/sliver_tools.dart';

Widget test() {
  return MultiSliver(
    children: [Container()],
  );
}
''',
      [lint(115, 11)],
    );
  }

  Future<void> test_zero_children_is_not_marked() async {
    await assertNoDiagnostics('''
import 'package:flutter/material.dart';

Widget test() {
  return const Wrap();
}
''');
  }

  Future<void> test_many_children_is_not_marked() async {
    await assertNoDiagnostics('''
import 'package:flutter/material.dart';

Widget test() {
  return Wrap(children: [Container(), Container(), Container()]);
}
''');
  }

  Future<void> test_collection_for_is_many() async {
    await assertNoDiagnostics('''
import 'package:flutter/material.dart';

Widget test() {
  return Wrap(children: [for (var i = 0; i < 3; i++) Container()]);
}
''');
  }

  Future<void> test_list_spread_is_many() async {
    await assertNoDiagnostics('''
import 'package:flutter/material.dart';

Widget test() {
  return Wrap(
    children: [
      ...[for (var i = 0; i < 3; i++) Container()],
    ],
  );
}
''');
  }

  Future<void> test_not_collection_literal_is_many() async {
    await assertNoDiagnostics('''
import 'package:flutter/material.dart';

Widget test() {
  final children = [Container(), Container(), Container()];

  return Wrap(children: children);
}
''');
  }

  Future<void> test_collection_if_is_marked() async {
    await assertDiagnostics(
      '''
import 'dart:math';
import 'package:flutter/material.dart';

Widget test() {
  return Wrap(
    children: [
      if (Random().nextBool())
        if (Random().nextBool())
          if (Random().nextBool()) Container(),
    ],
  );
}
''',
      [lint(86, 4)],
    );
  }

  Future<void> test_collection_if_else_is_marked() async {
    await assertDiagnostics(
      '''
import 'dart:math';
import 'package:flutter/material.dart';

Widget test() {
  return Wrap(
    children: [
      if (Random().nextBool())
        if (Random().nextBool()) Container() else Container(),
    ],
  );
}
''',
      [lint(86, 4)],
    );
  }

  Future<void> test_collection_if_is_not_marked_when_producing_many() async {
    await assertNoDiagnostics('''
import 'dart:math';
import 'package:flutter/material.dart';

Widget test() {
  return Wrap(
    children: [
      if (Random().nextBool())
        if (Random().nextBool())
          if (Random().nextBool())
            for (var i = 0; i < 3; i++) Container(),
    ],
  );
}
''');
  }

  Future<void>
  test_collection_if_is_not_marked_when_else_producing_many() async {
    await assertNoDiagnostics('''
import 'dart:math';
import 'package:flutter/material.dart';

Widget test() {
  return Wrap(
    children: [
      if (Random().nextBool())
        if (Random().nextBool())
          if (Random().nextBool())
            Container()
          else
            for (var i = 0; i < 3; i++) Container(),
    ],
  );
}
''');
  }
}
