import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

// expect_lint: hook_widget_does_not_use_hooks
class SampleHookWidgetNotUsingHooks extends HookWidget {
  const SampleHookWidgetNotUsingHooks({super.key});

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}

class SampleHookWidgetUsingHooks extends HookWidget {
  const SampleHookWidgetUsingHooks({super.key});

  @override
  Widget build(BuildContext context) {
    final a = useState('test');

    useAutomaticKeepAlive();

    return Container(
      key: Key(a.value),
    );
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

    return PageView(
      controller: usePageController(),
    );
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
