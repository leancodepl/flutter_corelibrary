import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class SampleHookWidget extends HookWidget {
  const SampleHookWidget({super.key});

  @override
  Widget build(BuildContext context) {
    if (Random().nextBool()) {
      // expect_lint: avoid_conditional_hooks
      useState('c');

      // expect_lint: avoid_conditional_hooks
      final a = useState('b');

      // expect_lint: avoid_conditional_hooks
      final b = Random().nextBool() ? useState('c') : null;
      // expect_lint: avoid_conditional_hooks
      final c = Random().nextBool() ? null : useState('c');

      const abc = 'aaa';

      return Container(
        key: Key('${a.value} $abc ${b?.value} ${c?.value}'),
      );
    }

    final test = useState('abc');

    // expect_lint: avoid_conditional_hooks
    final b = Random().nextBool() ? useState('c') : null;
    // expect_lint: avoid_conditional_hooks
    final c = Random().nextBool() ? null : useState('c');

    return Container(
      key: Key('$test ${b?.value} ${c?.value}'),
    );
  }
}
