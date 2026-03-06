import 'package:analyzer_testing/analysis_rule/analysis_rule.dart';
import 'package:leancode_lint/src/lints/never_discard_build_context.dart';
import 'package:test_reflective_loader/test_reflective_loader.dart';

import '../assert_ranges.dart';
import '../mock_libraries.dart';

void main() {
  defineReflectiveSuite(() {
    defineReflectiveTests(NeverDiscardBuildContextTest);
  });
}

@reflectiveTest
class NeverDiscardBuildContextTest extends AnalysisRuleTest with MockFlutter {
  @override
  void setUp() {
    rule = NeverDiscardBuildContext();

    super.setUp();
  }

  Future<void> test_namedParameter_flagged() async {
    await assertDiagnosticsInRanges('''
import 'package:flutter/material.dart';

Widget myBuilder(BuildContext [!_!]) {
  return const SizedBox();
}
''');
  }

  Future<void> test_builderCallback_flagged() async {
    await assertDiagnosticsInRanges('''
import 'package:flutter/material.dart';

class MyWidget extends StatelessWidget {
  const MyWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (BuildContext [!_!]) => const SizedBox(),
    );
  }
}
''');
  }

  Future<void> test_builderCallback_inferredType_flagged() async {
    await assertDiagnosticsInRanges('''
import 'package:flutter/material.dart';

class MyWidget extends StatelessWidget {
  const MyWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: ([!_!]) => const SizedBox(),
    );
  }
}
''');
  }

  Future<void> test_withExtraParameters_flagged() async {
    await assertDiagnosticsInRanges('''
import 'package:flutter/material.dart';

Widget myBuilder(BuildContext [!_!], Widget? child) {
  return child ?? const SizedBox();
}
''');
  }

  Future<void> test_namedContext_ok() async {
    await assertNoDiagnostics('''
import 'package:flutter/material.dart';

Widget myBuilder(BuildContext context) {
  return const SizedBox();
}
''');
  }

  Future<void> test_builderCallback_namedContext_ok() async {
    await assertNoDiagnostics('''
import 'package:flutter/material.dart';

class MyWidget extends StatelessWidget {
  const MyWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) => const SizedBox(),
    );
  }
}
''');
  }

  Future<void> test_buildMethod_ok() async {
    await assertNoDiagnostics('''
import 'package:flutter/material.dart';

class MyWidget extends StatelessWidget {
  const MyWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return const SizedBox();
  }
}
''');
  }

  Future<void> test_discardedNonBuildContext_ok() async {
    await assertNoDiagnostics('''
void doSomething(int _) {}
void doSomethingElse(String _) {}
''');
  }

  Future<void> test_multipleParameters_onlyContextDiscarded_flagged() async {
    await assertDiagnosticsInRanges('''
import 'package:flutter/material.dart';

typedef WidgetBuilderWithChild = Widget Function(BuildContext context, Widget? child);

Widget myBuilder(BuildContext [!_!], Widget? child) {
  return child ?? const SizedBox();
}
''');
  }

  Future<void> test_multipleWildcards_onlyContextFlagged() async {
    await assertDiagnosticsInRanges('''
import 'package:flutter/material.dart';

Widget myBuilder(BuildContext [!_!], int _) {
  return const SizedBox();
}
''');
  }

  Future<void> test_functionTypeInParameter_flagged() async {
    await assertDiagnosticsInRanges('''
import 'package:flutter/material.dart';

void run(Widget Function(BuildContext [!_!]) builder) {}
''');
  }

  Future<void> test_localFunction_flagged() async {
    await assertDiagnosticsInRanges('''
import 'package:flutter/material.dart';

class MyWidget extends StatelessWidget {
  const MyWidget({super.key});

  @override
  Widget build(BuildContext context) {
    Widget inner(BuildContext [!_!]) => const SizedBox();
    return inner(context);
  }
}
''');
  }

  Future<void> test_namedUnderscore_nonContext_ok() async {
    await assertNoDiagnostics('''
import 'package:flutter/material.dart';

class MyWidget extends StatelessWidget {
  const MyWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (ctx) {
        final result = [1, 2, 3].map((_) => const SizedBox()).toList();
        return Column(children: result);
      },
    );
  }
}
''');
  }

  Future<void> test_multipleBuilders_allFlagged() async {
    await assertDiagnosticsInRanges('''
import 'package:flutter/material.dart';

class MyWidget extends StatelessWidget {
  const MyWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Builder(builder: (BuildContext /*[0*/_/*0]*/) => const SizedBox()),
        Builder(builder: (BuildContext /*[1*/_/*1]*/) => const SizedBox()),
      ],
    );
  }
}
''');
  }
}
