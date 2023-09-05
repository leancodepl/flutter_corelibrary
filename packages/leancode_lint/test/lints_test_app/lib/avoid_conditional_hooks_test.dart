import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

void someOtherFunction() {
  final b = Random().nextBool() ? useState(true) : useState(false);

  if (b.value) {
    useState('a');
  }
}

class SampleHookWidget extends HookWidget {
  const SampleHookWidget({super.key});

  @override
  Widget build(BuildContext context) {
    if (Random().nextBool()) {
      // expect_lint: avoid_conditional_hooks
      useState('c');

      final a = // expect_lint: avoid_conditional_hooks
          useState('b');

      final b = Random().nextBool()
          ? // expect_lint: avoid_conditional_hooks
          useState('c')
          : null;

      final c = Random().nextBool()
          ? null
          : // expect_lint: avoid_conditional_hooks
          useState('c');

      const abc = 'aaa';

      return Container(
        key: Key('${a.value} $abc ${b?.value} ${c?.value}'),
      );
    }

    final test = useState('abc');

    final b = Random().nextBool()
        ? // expect_lint: avoid_conditional_hooks
        useState('c')
        : null;

    final c = Random().nextBool()
        ? null
        : // expect_lint: avoid_conditional_hooks
        useState('c');

    return Container(
      key: Key('$test ${b?.value} ${c?.value}'),
    );
  }
}

class SampleConditionalExpressionHookWidget extends HookWidget {
  const SampleConditionalExpressionHookWidget({super.key});

  @override
  Widget build(BuildContext context) => TextField(
        controller: Random().nextBool()
            ? // expect_lint: avoid_conditional_hooks
            useTextEditingController()
            : TextEditingController(),
      );
}

class SampleConditionalExpressionHookWidget2 extends HookWidget {
  const SampleConditionalExpressionHookWidget2({super.key});

  @override
  Widget build(BuildContext context) => Random().nextBool()
      ? TextField(
          controller: // expect_lint: avoid_conditional_hooks
              useTextEditingController(),
        )
      : Container();
}

class SampleNotConditionalExpressionHookWidget extends HookWidget {
  const SampleNotConditionalExpressionHookWidget({super.key});

  @override
  Widget build(BuildContext context) => TextField(
        controller: useTextEditingController(),
      );
}

class SampleSwitchExpressionHookWidget extends HookWidget {
  const SampleSwitchExpressionHookWidget({super.key});

  @override
  Widget build(BuildContext context) => switch (useTextEditingController()) {
        TextEditingController() => Container(),
      };
}

class SampleSwitchHookWidget extends HookWidget {
  const SampleSwitchHookWidget({super.key});

  @override
  Widget build(BuildContext context) {
    switch (Random().nextInt(10)) {
      case 5:
        final state =
            // expect_lint: avoid_conditional_hooks
            useState(false);

        return Container(key: Key(state.value.toString()));
    }

    return switch (Random().nextInt(10)) {
      5 => TextField(
          controller:
              // expect_lint: avoid_conditional_hooks
              useTextEditingController(),
        ),
      _ => const SizedBox(),
    };
  }
}
