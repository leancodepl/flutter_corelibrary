import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class SampleHookWidgetNotUsingHooks
    extends
        // expect_lint: hook_widget_does_not_use_hooks
        HookWidget {
  const SampleHookWidgetNotUsingHooks({super.key});

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}

class HookConsumerWidgetIsSeenAsAHookWidget
    extends
        // expect_lint: hook_widget_does_not_use_hooks
        HookConsumerWidget {
  const HookConsumerWidgetIsSeenAsAHookWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container();
  }
}

class SampleHookWidgetUsingHooks extends HookWidget {
  const SampleHookWidgetUsingHooks({super.key});

  @override
  Widget build(BuildContext context) {
    final a = useState('test');

    useAutomaticKeepAlive();

    return Container(key: Key(a.value));
  }
}

class HookWidgetUsingPrivateHook extends HookWidget {
  const HookWidgetUsingPrivateHook({super.key});

  @override
  Widget build(BuildContext context) {
    _usePrivateHook();

    return Container();
  }

  void _usePrivateHook() {}
}

class SampleStatelessWidget extends StatelessWidget {
  const SampleStatelessWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}

class WidgetUsingHookDirectlyInWidget extends HookWidget {
  const WidgetUsingHookDirectlyInWidget({super.key});

  @override
  Widget build(BuildContext context) {
    useTextEditingController();

    return PageView(controller: usePageController());
  }
}

class WidgetUsingHookWhichIsClassInstranceAlias extends HookWidget {
  const WidgetUsingHookWhichIsClassInstranceAlias({super.key});

  @override
  Widget build(BuildContext context) {
    useTextEditingController();

    return Container();
  }
}

class WidgetTransitivelyBeingAHookWidget extends SampleHookWidgetUsingHooks {
  const WidgetTransitivelyBeingAHookWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}

final a =
// expect_lint: hook_widget_does_not_use_hooks
HookBuilder(
  builder: (context) {
    return const SizedBox();
  },
);

final b = HookBuilder(
  builder: (context) {
    useState(123);
    return const SizedBox();
  },
);

final c =
// expect_lint: hook_widget_does_not_use_hooks
HookConsumer(
  builder: (context, ref, child) {
    return const SizedBox();
  },
);

// expect_lint: hook_widget_does_not_use_hooks
class HookBuilderIsASeparateHookContext extends HookWidget {
  const HookBuilderIsASeparateHookContext({super.key});

  @override
  Widget build(BuildContext context) {
    // expect_lint: hook_widget_does_not_use_hooks
    return HookBuilder(
      builder:
          (context) => HookBuilder(
            builder: (context) {
              useState(1);
              return const SizedBox();
            },
          ),
    );
  }
}
