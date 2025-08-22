// Test Bloc classes for avoid_missing_dispose lint
// ignore_for_file: unused_field, use_design_system_item

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CounterBloc extends Bloc<int, int> {
  CounterBloc() : super(0) {
    on<int>((event, emit) => emit(event + state));
  }
}

class BlocStatefulWidget extends StatefulWidget {
  const BlocStatefulWidget({super.key});

  @override
  State<BlocStatefulWidget> createState() => _BlocStatefulWidgetState();
}

class _BlocStatefulWidgetState extends State<BlocStatefulWidget> {
  late CounterBloc _counterBloc;
  // expect_lint: avoid_missing_dispose
  final _notDisposedBloc = CounterBloc();
  // expect_lint: avoid_missing_dispose
  late final CounterBloc _notDisposedBlocLate;

  @override
  void initState() {
    super.initState();
    _counterBloc = CounterBloc();
    _notDisposedBlocLate = CounterBloc();
  }

  @override
  void dispose() {
    _counterBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => const SizedBox();
}
