import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:leancode_hooks/leancode_hooks.dart';

class UsePostFrameEffectTestWidget extends HookWidget {
  const UsePostFrameEffectTestWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final called = useState(false);

    usePostFrameEffect(
      () => called.value = true,
    );

    return MaterialApp(
      home: Text(called.value.toString()),
    );
  }
}

void main() {
  testWidgets('effect gets called post frame', (tester) async {
    await tester.pumpWidget(const UsePostFrameEffectTestWidget());

    expect(find.text('true'), findsNothing);

    tester.binding.scheduleWarmUpFrame();

    expect(find.text('true'), findsOneWidget);
  });
}
