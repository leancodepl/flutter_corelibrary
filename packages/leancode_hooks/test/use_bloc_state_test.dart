import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:leancode_hooks/leancode_hooks.dart';

class SampleTestCubit extends Cubit<SampleTestCubitState> {
  SampleTestCubit() : super(SampleTestCubitState.first);

  void setState(SampleTestCubitState state) => emit(state);
}

enum SampleTestCubitState {
  first,
  second;
}

class UseBlocStateTestWidget extends HookWidget {
  const UseBlocStateTestWidget({
    Key? key,
    required this.cubit,
  }) : super(key: key);

  final SampleTestCubit cubit;

  @override
  Widget build(BuildContext context) {
    final state = useBlocState(cubit);

    return MaterialApp(
      home: Text(state.name),
    );
  }
}

void main() {
  testWidgets('UseBlocState refreshes widget on state change', (tester) async {
    const desiredState = SampleTestCubitState.second;
    final desiredText = desiredState.name;

    final cubit = SampleTestCubit();

    await tester.pumpWidget(UseBlocStateTestWidget(cubit: cubit));

    expect(find.text(desiredText), findsNothing);

    cubit.setState(desiredState);

    tester.binding.scheduleWarmUpFrame();

    expect(find.text(desiredText), findsOneWidget);

    await cubit.close();
  });
}
