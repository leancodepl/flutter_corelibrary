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
