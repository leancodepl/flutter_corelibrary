import 'package:analyzer/src/lint/registry.dart';
import 'package:analyzer_testing/analysis_rule/analysis_rule.dart';
import 'package:leancode_lint/lints/avoid_conditional_hooks.dart';
import 'package:test_reflective_loader/test_reflective_loader.dart';

import 'mock_libraries.dart';

void main() {
  defineReflectiveSuite(() {
    defineReflectiveTests(AvoidConditionalHooksTest);
  });
}

@reflectiveTest
class AvoidConditionalHooksTest extends AnalysisRuleTest {
  final rule = AvoidConditionalHooks();

  @override
  void setUp() {
    Registry.ruleRegistry.registerWarningRule(rule);
    super.setUp();

    addMocks([
      MockLibrary.flutter,
      MockLibrary.flutterHooks,
      MockLibrary.hooksRiverpod,
    ]);
  }

  @override
  String get analysisRule => rule.name;

  Future<void> test_hooksOutsideBuild() async {
    await assertNoDiagnostics('''
import 'dart:math';
import 'package:flutter_hooks/flutter_hooks.dart';

void someOtherFunction() {
  final b = Random().nextBool() ? useState(true) : useState(false);

  if (b.value) {
    useState('a');
  }
}
''');
  }

  Future<void> test_hookInsideIf() async {
    await assertDiagnostics(
      '''
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class SampleHookWidget extends HookWidget {
  const SampleHookWidget({super.key});

  @override
  Widget build(BuildContext context) {
    if (Random().nextBool()) {
      useState('c');
    }
    return Container();
  }
}
''',
      [lint(284, 13)],
    );
  }

  Future<void> test_similarPrefix() async {
    await assertNoDiagnostics('''
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class SampleHookWidget extends HookWidget {
  const SampleHookWidget({super.key});

  @override
  Widget build(BuildContext context) {
    void userSomething() {}

    if (Random().nextBool()) {
      userSomething();
    }
    return Container();
  }
}
  ''');
  }

  Future<void> test_hookInsideIf_assignedToVariable() async {
    await assertDiagnostics(
      '''
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class SampleHookWidget extends HookWidget {
  const SampleHookWidget({super.key});

  @override
  Widget build(BuildContext context) {
    if (Random().nextBool()) {
      final a = useState('b');
    }
    return Container();
  }
}
''',
      [lint(294, 13)],
    );
  }

  Future<void> test_hookInsideConditional_trueBranch() async {
    await assertDiagnostics(
      '''
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class SampleHookWidget extends HookWidget {
  const SampleHookWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final b = Random().nextBool() ? useState('c') : null;
    return Container();
  }
}
''',
      [lint(283, 13)],
    );
  }

  Future<void> test_hookInsideConditional_falseBranch() async {
    await assertDiagnostics(
      '''
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class SampleHookWidget extends HookWidget {
  const SampleHookWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Random().nextBool() ? null : useState('c');
    return Container();
  }
}
''',
      [lint(290, 13)],
    );
  }

  Future<void> test_unconditionalHook() async {
    await assertNoDiagnostics('''
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class SampleHookWidget extends HookWidget {
  const SampleHookWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final test = useState('abc');
    return Container(key: Key(test.value));
  }
}
''');
  }

  Future<void> test_hookInConditionalExpression_inArgument() async {
    await assertDiagnostics(
      '''
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class SampleConditionalExpressionHookWidget extends HookWidget {
  const SampleConditionalExpressionHookWidget({super.key});

  @override
  Widget build(BuildContext context) => TextField(
    controller: Random().nextBool()
        ? useTextEditingController()
        : TextEditingController(),
  );
}
''',
      [lint(347, 26)],
    );
  }

  Future<void> test_hookInConditionalExpression_inWidget() async {
    await assertDiagnostics(
      '''
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class SampleConditionalExpressionHookWidget extends HookWidget {
  const SampleConditionalExpressionHookWidget({super.key});

  @override
  Widget build(BuildContext context) => Random().nextBool()
      ? TextField(controller: useTextEditingController())
      : Container();
}
''',
      [lint(340, 26)],
    );
  }

  Future<void> test_hookInConsumerWidget() async {
    await assertDiagnostics(
      '''
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class HookConsumerWidgetIsSeenAsAHookWidget extends HookConsumerWidget {
  const HookConsumerWidgetIsSeenAsAHookWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) => Random().nextBool()
      ? TextField(controller: useTextEditingController())
      : Container();
}
''',
      [lint(416, 26)],
    );
  }

  Future<void> test_unconditionalHookInExpression() async {
    await assertNoDiagnostics('''
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class SampleNotConditionalExpressionHookWidget extends HookWidget {
  const SampleNotConditionalExpressionHookWidget({super.key});

  @override
  Widget build(BuildContext context) =>
      TextField(controller: useTextEditingController());
}
''');
  }

  Future<void> test_hookInSwitchExpression() async {
    await assertNoDiagnostics('''
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class SampleSwitchExpressionHookWidget extends HookWidget {
  const SampleSwitchExpressionHookWidget({super.key});

  @override
  Widget build(BuildContext context) => switch (useTextEditingController()) {
    TextEditingController() => Container(),
  };
}
''');
  }

  Future<void> test_hookInSwitchStatement_case() async {
    await assertDiagnostics(
      '''
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class SampleSwitchHookWidget extends HookWidget {
  const SampleSwitchHookWidget({super.key});

  @override
  Widget build(BuildContext context) {
    switch (Random().nextInt(10)) {
      case 5:
        final state = useState(false);
        return Container(key: Key(state.value.toString()));
    }
    return const SizedBox();
  }
}
''',
      [lint(331, 15)],
    );
  }

  Future<void> test_hookInSwitchExpression_case() async {
    await assertDiagnostics(
      '''
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class SampleSwitchHookWidget extends HookWidget {
  const SampleSwitchHookWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return switch (Random().nextInt(10)) {
      5 => TextField(controller: useTextEditingController()),
      _ => const SizedBox(),
    };
  }
}
''',
      [lint(335, 26)],
    );
  }

  Future<void> test_hookInShortCircuit_ifOr() async {
    await assertDiagnostics(
      '''
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class ShortCircuits extends HookWidget {
  const ShortCircuits({super.key});

  @override
  Widget build(BuildContext context) {
    if (useContext().mounted || Random().nextBool()) {}
    if (Random().nextBool() || useContext().mounted) {}
    return const SizedBox();
  }
}
''',
      [lint(328, 12)],
    );
  }

  Future<void> test_hookInShortCircuit_ifAnd() async {
    await assertDiagnostics(
      '''
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class ShortCircuits extends HookWidget {
  const ShortCircuits({super.key});

  @override
  Widget build(BuildContext context) {
    if (useContext().mounted && Random().nextBool()) {}
    if (Random().nextBool() && useContext().mounted) {}
    return const SizedBox();
  }
}
''',
      [lint(328, 12)],
    );
  }

  Future<void> test_hookInShortCircuit_assignment() async {
    await assertDiagnostics(
      r'''
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class ShortCircuits extends HookWidget {
  const ShortCircuits({super.key, this.notifier});

  final ValueNotifier<int>? notifier;

  @override
  Widget build(BuildContext context) {
    final a1 = useMemoized(() => null) ?? 123;
    final a2 = notifier ?? useState(1);
    
    throw Exception('$a1 $a2');
  }
}
''',
      [lint(349, 11)],
    );
  }

  Future<void> test_compoundAssignment_shortCircuit() async {
    await assertDiagnostics(
      r'''
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class ShortCircuits extends HookWidget {
  const ShortCircuits({super.key, this.notifier});

  final ValueNotifier<int>? notifier;

  @override
  Widget build(BuildContext context) {
    ValueNotifier<int>? b;
    b ??= useState(1);

    var c = true;
    c |= useContext().mounted;
    c &= useContext().mounted;
    c ^= useContext().mounted;

    throw Exception('$b $c');
  }
}
''',
      // TODO: logical compound operators don't seem to short-circuit???
      [lint(312, 11), lint(353, 12), lint(384, 12), lint(415, 12)],
    );
  }

  Future<void> test_hookAfterReturn() async {
    await assertDiagnostics(
      r'''
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class HookAfterReturn extends HookWidget {
  const HookAfterReturn({super.key});

  @override
  Widget build(BuildContext context) {
    final a = useState(1);

    if (Random().nextBool()) {
      return const SizedBox();
    }

    final b = useState(1);

    throw Exception('$a $b');
  }
}
''',
      [lint(356, 11)],
    );
  }

  Future<void> test_hookInCollectionIf() async {
    await assertDiagnostics(
      '''
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class CollectionIf extends HookWidget {
  const CollectionIf({super.key});

  @override
  Widget build(BuildContext context) {
    final a = [if (Random().nextBool()) useState(1)];

    throw Exception(a);
  }
}
''',
      [lint(279, 11)],
    );
  }

  Future<void> test_hookInHookBuilder() async {
    await assertDiagnostics(
      '''
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

final a = HookBuilder(
  builder: (context) {
    if (Random().nextBool()) {
      useState(1);
    }
    useState(2);
    return const SizedBox();
  },
);
''',
      [lint(195, 11)],
    );
  }

  Future<void> test_hookInHookConsumer() async {
    await assertDiagnostics(
      '''
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final b = HookConsumer(
  builder: (context, ref, child) {
    if (Random().nextBool()) {
      useState(1);
    }
    useState(2);
    return const SizedBox();
  },
);
''',
      [lint(261, 11)],
    );
  }

  Future<void> test_hookBuilderInIfIsOk() async {
    await assertNoDiagnostics('''
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class HookBuilderInIfIsOk extends StatelessWidget {
  const HookBuilderInIfIsOk({super.key});

  @override
  Widget build(BuildContext context) {
    if (Random().nextBool()) {
      return HookBuilder(
        builder: (context) {
          useState(1);
          return const SizedBox();
        },
      );
    }

    return const SizedBox();
  }
}
''');
  }

  Future<void> test_immediatelyInvokedFunctionExpressionIsDetected() async {
    await assertDiagnostics(
      '''
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class ImmediatelyInvokedFunctionExpressionIsDetected extends HookWidget {
  const ImmediatelyInvokedFunctionExpressionIsDetected({super.key});

  @override
  Widget build(BuildContext context) {
    if (Random().nextBool()) {
      return () {
        useState(1);
        return const SizedBox();
      }();
    }

    return const SizedBox();
  }
}
''',
      [lint(364, 11)],
    );
  }

  Future<void> test_hookBuilderInHookWidgetShouldBeOk() async {
    await assertNoDiagnostics('''
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class HookBuilderInHookWidgetShouldBeOk extends HookWidget {
  const HookBuilderInHookWidgetShouldBeOk({super.key});

  @override
  Widget build(BuildContext context) {
    useState(1);
    if (Random().nextBool()) {
      return const SizedBox();
    }

    return HookBuilder(
      builder: (context) {
        useState(1);
        return const SizedBox();
      },
    );
  }
}
''');
  }
}
