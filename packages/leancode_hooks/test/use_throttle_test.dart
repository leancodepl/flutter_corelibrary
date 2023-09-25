import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:leancode_hooks/leancode_hooks.dart';

const duration = Duration(milliseconds: 300);
const textA = 'A';
const textB = 'B';
const textC = 'C';

class UseThrottleTestWidget extends HookWidget {
  const UseThrottleTestWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final state = useState(textA);
    final throttle = useThrottle(duration);

    void updateText() {
      if (state.value == textA) {
        state.value = textB;
      } else if (state.value == textB) {
        state.value = textC;
      }
    }

    return MaterialApp(
      home: GestureDetector(
        onTap: () => throttle(updateText),
        child: Text(state.value),
      ),
    );
  }
}

void main() {
  testWidgets('throttles calls to callback', (tester) async {
    await tester.runAsync<void>(() async {
      await tester.pumpWidget(const UseThrottleTestWidget());

      final text = find.byType(GestureDetector);
      expect(find.text(textA), findsOneWidget);

      await tester.tap(text);
      await tester.pump();

      expect(find.text(textB), findsOneWidget);

      await tester.tap(text);
      await tester.pump();
      expect(find.text(textB), findsOneWidget);

      await tester.tap(text);
      await tester.pump();
      expect(find.text(textB), findsOneWidget);

      await tester.tap(text);
      await tester.pump();
      expect(find.text(textB), findsOneWidget);

      expect(find.text(textB), findsOneWidget);

      await tester.pumpAndSettle(duration);
      await Future<void>.delayed(duration);

      await tester.tap(text);
      await tester.pump();

      expect(find.text(textC), findsOneWidget);
    });
  });
}
