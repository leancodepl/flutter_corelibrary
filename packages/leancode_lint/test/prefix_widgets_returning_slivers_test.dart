import 'package:analyzer/src/lint/registry.dart';
import 'package:analyzer_testing/analysis_rule/analysis_rule.dart';
import 'package:leancode_lint/lints/prefix_widgets_returning_slivers.dart';
import 'package:test_reflective_loader/test_reflective_loader.dart';

import 'mock_libraries.dart';

void main() {
  defineReflectiveSuite(() {
    defineReflectiveTests(PrefixWidgetsReturningSliversTest);
  });
}

@reflectiveTest
class PrefixWidgetsReturningSliversTest extends AnalysisRuleTest {
  final rule = PrefixWidgetsReturningSlivers();

  @override
  void setUp() {
    Registry.ruleRegistry.registerWarningRule(rule);
    super.setUp();

    addMocks([MockLibrary.flutter]);
    addAnalysisOptions();
  }

  @override
  String get analysisRule => rule.name;

  Future<void> test_return_from_internal_blocks() async {
    await assertDiagnostics(
      '''
import 'dart:math';

import 'package:flutter/material.dart';

class WidgetReturningSliverFromInternalBlocks extends StatelessWidget {
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
''',
      [lint(68, 39)],
    );
  }

  Future<void> test_stateful() async {
    await assertDiagnostics(
      '''
import 'package:flutter/material.dart';

class Stateful extends StatefulWidget {
  const Stateful({super.key});

  @override
  State<Stateful> createState() => _StatefulState();
}

class _StatefulState extends State<Stateful> {
  @override
  Widget build(BuildContext context) {
    return const SliverToBoxAdapter();
  }
}
''',
      [lint(187, 14)],
    );
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
    await assertDiagnostics(
      '''
import 'package:flutter/material.dart';

class NotPrefixedWidgetReturningSliver extends StatelessWidget {
  const NotPrefixedWidgetReturningSliver({super.key});

  @override
  Widget build(BuildContext context) {
    return const SliverToBoxAdapter();
  }
}
''',
      [lint(47, 32)],
    );
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
    await assertDiagnostics(
      '''
import 'package:flutter/material.dart';

class LncdSliverPrefixedWidgetReturningSliver extends StatelessWidget {
  const LncdSliverPrefixedWidgetReturningSliver({super.key});

  @override
  Widget build(BuildContext context) {
    return const SliverToBoxAdapter();
  }
}

class LncdReturningAppPrefixedSliver extends StatelessWidget {
  const LncdReturningAppPrefixedSliver({super.key});

  @override
  Widget build(BuildContext context) {
    return const LncdSliverPrefixedWidgetReturningSliver();
  }
}
''',
      [lint(279, 30)],
    );
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
