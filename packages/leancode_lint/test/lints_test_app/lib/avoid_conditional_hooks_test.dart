import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

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
    void userSomething() {}

    if (Random().nextBool()) {
      // expect_lint: avoid_conditional_hooks
      useState('c');
      userSomething();

      final a = // expect_lint: avoid_conditional_hooks
          useState('b');

      final b =
          Random().nextBool()
              ? // expect_lint: avoid_conditional_hooks
              useState('c')
              : null;

      final c =
          Random().nextBool()
              ? null
              : // expect_lint: avoid_conditional_hooks
              useState('c');

      const abc = 'aaa';

      debugPrint('$a$b$c$abc');
    }

    final test = useState('abc');

    final b =
        Random().nextBool()
            ? // expect_lint: avoid_conditional_hooks
            useState('c')
            : null;

    final c =
        Random().nextBool()
            ? null
            : // expect_lint: avoid_conditional_hooks
            useState('c');

    return Container(key: Key('$test ${b?.value} ${c?.value}'));
  }
}

class SampleConditionalExpressionHookWidget extends HookWidget {
  const SampleConditionalExpressionHookWidget({super.key});

  @override
  Widget build(BuildContext context) => TextField(
    controller:
        Random().nextBool()
            ? // expect_lint: avoid_conditional_hooks
            useTextEditingController()
            // expect_lint: avoid_missing_dispose
            : TextEditingController(),
  );
}

class SampleConditionalExpressionHookWidget2 extends HookWidget {
  const SampleConditionalExpressionHookWidget2({super.key});

  @override
  Widget build(BuildContext context) =>
      Random().nextBool()
          ? TextField(
            controller: // expect_lint: avoid_conditional_hooks
                useTextEditingController(),
          )
          : Container();
}

class HookConsumerWidgetIsSeenAsAHookWidget extends HookConsumerWidget {
  const HookConsumerWidgetIsSeenAsAHookWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) =>
      Random().nextBool()
          ? TextField(
            controller: // expect_lint: avoid_conditional_hooks
                useTextEditingController(),
          )
          : Container();
}

class SampleNotConditionalExpressionHookWidget extends HookWidget {
  const SampleNotConditionalExpressionHookWidget({super.key});

  @override
  Widget build(BuildContext context) =>
      TextField(controller: useTextEditingController());
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

class ShortCircuits extends HookWidget {
  const ShortCircuits({super.key, this.notifier});

  final ValueNotifier<int>? notifier;

  @override
  Widget build(BuildContext context) {
    final a1 = useMemoized(() => null) ?? 123;
    final a2 =
        notifier ??
        // expect_lint: avoid_conditional_hooks
        useState(1);

    if (useContext().mounted || Random().nextBool()) {}
    if (Random().nextBool() ||
        // expect_lint: avoid_conditional_hooks
        useContext().mounted) {}
    if (useContext().mounted && Random().nextBool()) {}
    if (Random().nextBool() &&
        // expect_lint: avoid_conditional_hooks
        useContext().mounted) {}

    ValueNotifier<int>? b;
    b ??=
    // expect_lint: avoid_conditional_hooks
    useState(1);

    var c = true;
    c |=
        // expect_lint: avoid_conditional_hooks
        useContext().mounted;
    c &=
        // expect_lint: avoid_conditional_hooks
        useContext().mounted;
    c ^=
        // expect_lint: avoid_conditional_hooks
        useContext().mounted;

    throw Exception('$a1$a2$c');
  }
}

class HookAfterReturn extends HookWidget {
  const HookAfterReturn({super.key});

  @override
  Widget build(BuildContext context) {
    final a = useState(1);

    if (Random().nextBool()) {
      return const SizedBox();
    }

    final b =
    // expect_lint: avoid_conditional_hooks
    useState(1);

    throw Exception('$a$b');
  }
}

class CollectionIf extends HookWidget {
  const CollectionIf({super.key});

  @override
  Widget build(BuildContext context) {
    final a = [
      if (Random().nextBool())
        // expect_lint: avoid_conditional_hooks
        useState(1),
    ];

    throw Exception('$a');
  }
}

final a = HookBuilder(
  builder: (context) {
    if (Random().nextBool()) {
      // expect_lint: avoid_conditional_hooks
      useState(1);
    }
    useState(2);
    return const SizedBox();
  },
);

final b = HookConsumer(
  builder: (context, ref, child) {
    if (Random().nextBool()) {
      // expect_lint: avoid_conditional_hooks
      useState(1);
    }
    useState(2);
    return const SizedBox();
  },
);

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

class ImmediatelyInvokedFunctionExpressionIsDetected extends HookWidget {
  const ImmediatelyInvokedFunctionExpressionIsDetected({super.key});

  @override
  Widget build(BuildContext context) {
    if (Random().nextBool()) {
      return () {
        // expect_lint: avoid_conditional_hooks
        useState(1);
        return const SizedBox();
      }();
    }

    return const SizedBox();
  }
}

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
