import 'package:analyzer_testing/analysis_rule/analysis_rule.dart';
import 'package:leancode_lint/lints/prefix_widgets_returning_slivers.dart';
import 'package:test_reflective_loader/test_reflective_loader.dart';

import '../assert_ranges.dart';
import '../mock_libraries.dart';

void main() {
  defineReflectiveSuite(() {
    defineReflectiveTests(PrefixWidgetsReturningSliversTest);
  });
}

@reflectiveTest
class PrefixWidgetsReturningSliversTest extends AnalysisRuleTest {
  @override
  void setUp() {
    rule = PrefixWidgetsReturningSlivers(
      config: const .new(applicationPrefix: 'Lncd'),
    );
    super.setUp();

    addMocks([.flutter]);
  }

  Future<void> test_return_from_internal_blocks() async {
    await assertDiagnosticsInRanges('''
import 'dart:math';

import 'package:flutter/material.dart';

class [!WidgetReturningSliverFromInternalBlocks!] extends StatelessWidget {
  const WidgetReturningSliverFromInternalBlocks({super.key});

  @override
  Widget build(BuildContext context) {
    if (Random().nextBool()) {
      return const SliverToBoxAdapter();
    } else {
      return const SliverToBoxAdapter();
    }
  }
}
''');
  }

  Future<void> test_stateful() async {
    await assertDiagnosticsInRanges('''
import 'package:flutter/material.dart';

class Stateful extends StatefulWidget {
  const Stateful({super.key});

  @override
  State<Stateful> createState() => _StatefulState();
}

class [!_StatefulState!] extends State<Stateful> {
  @override
  Widget build(BuildContext context) {
    return const SliverToBoxAdapter();
  }
}
''');
  }

  Future<void> test_impostor() async {
    await assertNoDiagnostics('''
import 'package:flutter/material.dart';

abstract class WidgetImpostorInterface {
  Widget build(BuildContext context);
}

class WidgetImpostor extends WidgetImpostorInterface {
  WidgetImpostor();

  @override
  Widget build(BuildContext context) {
    return const SliverToBoxAdapter();
  }
}
''');
  }

  Future<void> test_not_prefixed() async {
    await assertDiagnosticsInRanges('''
import 'package:flutter/material.dart';

class [!NotPrefixedWidgetReturningSliver!] extends StatelessWidget {
  const NotPrefixedWidgetReturningSliver({super.key});

  @override
  Widget build(BuildContext context) {
    return const SliverToBoxAdapter();
  }
}
''');
  }

  Future<void> test_prefixed_public() async {
    await assertNoDiagnostics('''
import 'package:flutter/material.dart';

class SliverPrefixedWidgetReturningSliver extends StatelessWidget {
  const SliverPrefixedWidgetReturningSliver({super.key});

  @override
  Widget build(BuildContext context) {
    return const SliverToBoxAdapter();
  }
}''');
  }

  Future<void> test_app_prefixed_public() async {
    await assertNoDiagnostics('''
import 'package:flutter/material.dart';

class LncdSliverPrefixedWidgetReturningSliver extends StatelessWidget {
  const LncdSliverPrefixedWidgetReturningSliver({super.key});

  @override
  Widget build(BuildContext context) {
    return const SliverToBoxAdapter();
  }
}
''');
  }

  Future<void> test_app_prefixed_private() async {
    await assertNoDiagnostics('''
import 'package:flutter/material.dart';

class _LncdSliverPrefixedWidgetReturningSliver extends StatelessWidget {
  const _LncdSliverPrefixedWidgetReturningSliver();

  @override
  Widget build(BuildContext context) {
    return const SliverToBoxAdapter();
  }
}
''');
  }

  Future<void> test_returning_app_prefixed_sliver() async {
    await assertDiagnosticsInRanges('''
import 'package:flutter/material.dart';

class LncdSliverPrefixedWidgetReturningSliver extends StatelessWidget {
  const LncdSliverPrefixedWidgetReturningSliver({super.key});

  @override
  Widget build(BuildContext context) {
    return const SliverToBoxAdapter();
  }
}

class [!LncdReturningAppPrefixedSliver!] extends StatelessWidget {
  const LncdReturningAppPrefixedSliver({super.key});

  @override
  Widget build(BuildContext context) {
    return const LncdSliverPrefixedWidgetReturningSliver();
  }
}
''');
  }

  Future<void> test_not_prefix_not_returning_sliver() async {
    await assertNoDiagnostics('''
import 'package:flutter/material.dart';

class NotPrefixedWidgetNotReturningSliver extends StatelessWidget {
  const NotPrefixedWidgetNotReturningSliver({super.key});

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) {
        return const SizedBox();
      },
    );
  }
}
''');
  }
}
