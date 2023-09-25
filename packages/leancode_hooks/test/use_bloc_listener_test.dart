import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:leancode_hooks/leancode_hooks.dart';

import 'use_bloc_state_test.dart';

class UseBlocListenerTestWidget extends HookWidget {
  const UseBlocListenerTestWidget({
    super.key,
    required this.cubit,
  });

  final SampleTestCubit cubit;

  @override
  Widget build(BuildContext context) {
    final content = useState('');

    useBlocListener<SampleTestCubitState>(
      bloc: cubit,
      listener: (state) => content.value = state.name,
    );

    return MaterialApp(
      home: Text(content.value),
    );
  }
}

void main() {
  testWidgets('UseBlocListener runs on state change', (tester) async {
    const desiredState = SampleTestCubitState.second;
    final desiredText = desiredState.name;

    final cubit = SampleTestCubit();

    await tester.pumpWidget(UseBlocListenerTestWidget(cubit: cubit));

    expect(find.text(desiredText), findsNothing);

    cubit.setState(desiredState);

    tester.binding.scheduleWarmUpFrame();

    expect(find.text(desiredText), findsOneWidget);

    await cubit.close();
  });
}
