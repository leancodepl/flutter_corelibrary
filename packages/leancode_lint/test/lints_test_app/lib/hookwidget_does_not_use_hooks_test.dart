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

class SampleStatelessWidget extends StatelessWidget {
  const SampleStatelessWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
