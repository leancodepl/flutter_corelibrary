import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:leancode_hooks/leancode_hooks.dart';

class UsePostFrameEffectTestWidget extends HookWidget {
  const UsePostFrameEffectTestWidget({super.key});

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

class UsePostFrameEffectWithNullKeysTestWidget extends HookWidget {
  const UsePostFrameEffectWithNullKeysTestWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final counter = useState(0);
    final effectCallCount = useState(0);

    usePostFrameEffect(
      () => effectCallCount.value++,
      keys: null,
    );

    return MaterialApp(
      home: Column(
        children: [
          Text('counter: ${counter.value}'),
          Text('effectCallCount: ${effectCallCount.value}'),
          ElevatedButton(
            onPressed: () => counter.value++,
            child: const Text('Increment'),
          ),
        ],
      ),
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

  testWidgets('effect runs on every build when keys is null', (tester) async {
    await tester.pumpWidget(const UsePostFrameEffectWithNullKeysTestWidget());

    // Initial state - effect hasn't run yet
    expect(find.text('effectCallCount: 0'), findsOneWidget);

    // Trigger post-frame callback
    tester.binding.scheduleWarmUpFrame();

    // Effect should have been called once
    expect(find.text('effectCallCount: 1'), findsOneWidget);

    // Trigger a rebuild by clicking the button
    await tester.tap(find.byType(ElevatedButton));
    await tester.pump();

    // Post-frame callback should be scheduled, but not yet executed
    expect(find.text('effectCallCount: 1'), findsOneWidget);

    // Execute post-frame callback
    tester.binding.scheduleWarmUpFrame();

    // Effect should have been called again
    expect(find.text('effectCallCount: 2'), findsOneWidget);

    // Trigger another rebuild
    await tester.tap(find.byType(ElevatedButton));
    await tester.pump();

    // Execute post-frame callback
    tester.binding.scheduleWarmUpFrame();

    // Effect should have been called a third time
    expect(find.text('effectCallCount: 3'), findsOneWidget);
  });
}
