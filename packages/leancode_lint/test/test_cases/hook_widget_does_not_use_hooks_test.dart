import 'package:analyzer_testing/analysis_rule/analysis_rule.dart';
import 'package:leancode_lint/lints/hook_widget_does_not_use_hooks.dart';
import 'package:test_reflective_loader/test_reflective_loader.dart';

import '../assert_ranges.dart';
import '../mock_libraries.dart';
import '../mock_libraries/flutter.dart';

void main() {
  defineReflectiveSuite(() {
    defineReflectiveTests(HookWidgetDoesNotUseHooksTest);
  });
}

@reflectiveTest
class HookWidgetDoesNotUseHooksTest extends AnalysisRuleTest with MockFlutter {
  @override
  void setUp() {
    rule = HookWidgetDoesNotUseHooks();
    addMocks([.flutterHooks, .hooksRiverpod]);

    super.setUp();
  }

  Future<void> test_sample_hook_widget_not_using_hooks() async {
    await assertDiagnosticsInRanges('''
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class SampleHookWidgetNotUsingHooks extends [!HookWidget!] {
  const SampleHookWidgetNotUsingHooks({super.key});

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
''');
  }

  Future<void> test_hook_consumer_widget_is_seem_as_a_hook_widget() async {
    await assertDiagnosticsInRanges('''
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class HookConsumerWidgetIsSeenAsAHookWidget extends [!HookConsumerWidget!] {
  const HookConsumerWidgetIsSeenAsAHookWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container();
  }
}
''');
  }

  Future<void> test_sample_hook_widget_using_hooks() async {
    await assertNoDiagnostics('''
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class SampleHookWidgetUsingHooks extends HookWidget {
  const SampleHookWidgetUsingHooks({super.key});

  @override
  Widget build(BuildContext context) {
    final a = useState('test');

    useAutomaticKeepAlive();

    return Container(key: Key(a.value));
  }
}
''');
  }

  Future<void> test_hook_widget_using_private_hook() async {
    await assertNoDiagnostics('''
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class HookWidgetUsingPrivateHook extends HookWidget {
  const HookWidgetUsingPrivateHook({super.key});

  @override
  Widget build(BuildContext context) {
    _usePrivateHook();

    return Container();
  }

  void _usePrivateHook() {}
}
''');
  }

  Future<void> test_sample_stateless_widget() async {
    await assertNoDiagnostics('''
import 'package:flutter/material.dart';

class SampleStatelessWidget extends StatelessWidget {
  const SampleStatelessWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
''');
  }

  Future<void> test_widget_using_hooks_directly_in_widget() async {
    await assertNoDiagnostics('''
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class WidgetUsingHooksDirectlyInWidget extends HookWidget {
  const WidgetUsingHooksDirectlyInWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return PageView(controller: usePageController());
  }
}
''');
  }

  Future<void> test_widget_using_class_instance_hook() async {
    await assertNoDiagnostics('''
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class WidgetUsingClassInstanceHook extends HookWidget {
  const WidgetUsingClassInstanceHook({super.key});

  @override
  Widget build(BuildContext context) {
    useTextEditingController();

    return Container();
  }
}
''');
  }

  Future<void> test_widget_transitively_being_a_hook_widget() async {
    await assertNoDiagnostics('''
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class SampleHookWidgetUsingHooks extends HookWidget {
  const SampleHookWidgetUsingHooks({super.key});

  @override
  Widget build(BuildContext context) {
    final a = useState('test');
    return Container(key: Key(a.value));
  }
}

class WidgetTransitivelyBeingAHookWidget extends SampleHookWidgetUsingHooks {
  const WidgetTransitivelyBeingAHookWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
''');
  }

  Future<void> test_hook_builder_no_hooks() async {
    await assertDiagnosticsInRanges('''
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

final a = [!HookBuilder!](
  builder: (context) {
    return const SizedBox();
  },
);
''');
  }

  Future<void> test_hook_builder_using_hooks() async {
    await assertNoDiagnostics('''
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

final b = HookBuilder(
  builder: (context) {
    useState(123);
    return const SizedBox();
  },
);  
''');
  }

  Future<void> test_hook_consumer() async {
    await assertDiagnosticsInRanges('''
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final c = [!HookConsumer!](
  builder: (context, ref, child) {
    return const SizedBox();
  },
);
''');
  }

  Future<void> test_hook_builder_is_a_separate_hook_context() async {
    await assertDiagnosticsInRanges('''
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class HookBuilderIsASeparateHookContext extends /*[0*/HookWidget/*0]*/ {
  const HookBuilderIsASeparateHookContext({super.key});

  @override
  Widget build(BuildContext context) {
    return /*[1*/HookBuilder/*1]*/(
      builder: (context) => HookBuilder(
        builder: (context) {
          useState(1);
          return const SizedBox();
        },
      ),
    );
  }
}
''');
  }
}
