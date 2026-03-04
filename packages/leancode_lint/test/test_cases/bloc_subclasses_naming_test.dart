import 'package:analyzer_testing/analysis_rule/analysis_rule.dart';
import 'package:leancode_lint/src/lints/bloc_subclasses_naming.dart';
import 'package:test_reflective_loader/test_reflective_loader.dart';

import '../assert_ranges.dart';
import '../mock_libraries.dart';

void main() {
  defineReflectiveSuite(() {
    defineReflectiveTests(BlocSubclassesNamingTest);
  });
}

@reflectiveTest
class BlocSubclassesNamingTest extends AnalysisRuleTest
    with MockBloc, MockBlocPresentation, MockFlutterBloc {
  @override
  void setUp() {
    rule = BlocSubclassesNaming();
    super.setUp();
  }

  Future<void> test_bloc_state_subclasses() async {
    await assertDiagnosticsInRanges('''
import 'package:bloc/bloc.dart';

class MyState {}
class MyStateInitial extends MyState {}
class MyStateLoaded extends MyState {}
class /*[0*/WrongName/*0]*/ extends MyState {}
class /*[1*/AlsoWrong/*1]*/ extends MyState {}

class MyBloc extends Bloc<MyEvent, MyState> {
  MyBloc() : super(MyStateInitial());
}

class MyEvent {}
''');
  }

  Future<void> test_bloc_event_subclasses() async {
    await assertDiagnosticsInRanges('''
import 'package:bloc/bloc.dart';

class MyEvent {}
class MyEventLoad extends MyEvent {}
class MyEventReset extends MyEvent {}
class [!WrongEvent!] extends MyEvent {}

class MyState {}

class MyBloc extends Bloc<MyEvent, MyState> {
  MyBloc() : super(MyState());
}
''');
  }

  Future<void> test_cubit_state_subclasses() async {
    await assertDiagnosticsInRanges('''
import 'package:bloc/bloc.dart';

class MyState {}
class MyStateInitial extends MyState {}
class [!WrongState!] extends MyState {}

class MyCubit extends Cubit<MyState> {
  MyCubit() : super(MyStateInitial());
}
''');
  }

  Future<void> test_presentation_event_subclasses() async {
    await assertDiagnosticsInRanges('''
import 'package:bloc/bloc.dart';
import 'package:bloc_presentation/bloc_presentation.dart';

class MyState {}
class MyPresentationEvent {}
class MyPresentationEventSuccess extends MyPresentationEvent {}
class [!WrongOutput!] extends MyPresentationEvent {}

class MyCubit extends Cubit<MyState>
    with BlocPresentationMixin<MyState, MyPresentationEvent> {
  MyCubit() : super(MyState());
}
''');
  }

  Future<void> test_no_diagnostics_when_correctly_named() async {
    await assertNoDiagnostics('''
import 'package:bloc/bloc.dart';
import 'package:bloc_presentation/bloc_presentation.dart';

class MyState {}
class MyStateInitial extends MyState {}
class MyStateLoaded extends MyState {}

class MyEvent {}
class MyEventLoad extends MyEvent {}
class MyEventReset extends MyEvent {}

class MyPresentationEvent {}
class MyPresentationEventSuccess extends MyPresentationEvent {}

class MyBloc extends Bloc<MyEvent, MyState>
    with BlocPresentationMixin<MyState, MyPresentationEvent> {
  MyBloc() : super(MyStateInitial());
}
''');
  }

  Future<void> test_unrelated_classes_ignored() async {
    await assertNoDiagnostics('''
import 'package:bloc/bloc.dart';

class MyState {}
class MyBloc extends Bloc<MyEvent, MyState> {
  MyBloc() : super(MyState());
}
class MyEvent {}

class UnrelatedBase {}
class WrongChild extends UnrelatedBase {}
''');
  }

  Future<void> test_classes_without_bloc_in_library_ignored() async {
    await assertNoDiagnostics('''
class SomeState {}
class WhateverSubclass extends SomeState {}
''');
  }

  Future<void> test_nested_hierarchy_correctly_named() async {
    await assertNoDiagnostics('''
import 'package:bloc/bloc.dart';

class MyState {}
class MyStateLoaded extends MyState {}
class MyStateEmpty extends MyStateLoaded {}
class MyStateSingle extends MyStateLoaded {}
class MyStateEmptier extends MyStateEmpty {}

class MyEvent {}

class MyBloc extends Bloc<MyEvent, MyState> {
  MyBloc() : super(MyState());
}
''');
  }

  Future<void> test_nested_hierarchy_wrong_name() async {
    await assertDiagnosticsInRanges('''
import 'package:bloc/bloc.dart';

class MyState {}
class MyStateLoaded extends MyState {}
class [!WrongName!] extends MyStateLoaded {}

class MyEvent {}

class MyBloc extends Bloc<MyEvent, MyState> {
  MyBloc() : super(MyState());
}
''');
  }

  Future<void> test_nested_hierarchy_wrong_at_multiple_levels() async {
    await assertDiagnosticsInRanges('''
import 'package:bloc/bloc.dart';

class MyState {}
class /*[0*/WrongName/*0]*/ extends MyState {}
class /*[1*/AnotherWrongName/*1]*/ extends WrongName {}

class MyEvent {}

class MyBloc extends Bloc<MyEvent, MyState> {
  MyBloc() : super(MyState());
}
''');
  }

  Future<void> test_custom_named_base_classes() async {
    await assertDiagnosticsInRanges('''
import 'package:bloc/bloc.dart';

class WeirdBase {}
class WeirdBaseLoaded extends WeirdBase {}
class [!WrongName!] extends WeirdBase {}

class WeirdEvent {}

class AnotherBloc extends Bloc<WeirdEvent, WeirdBase> {
  AnotherBloc() : super(WeirdBaseLoaded());
}
''');
  }
}
