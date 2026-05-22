import 'package:analyzer_testing/analysis_rule/analysis_rule.dart';
import 'package:leancode_lint/src/lints/bloc_class_modifiers.dart';
import 'package:test_reflective_loader/test_reflective_loader.dart';

import '../assert_ranges.dart';
import '../mock_libraries.dart';

void main() {
  defineReflectiveSuite(() {
    defineReflectiveTests(BlocClassModifiersTest);
  });
}

@reflectiveTest
class BlocClassModifiersTest extends AnalysisRuleTest
    with MockBloc, MockBlocPresentation, MockFlutterBloc {
  @override
  void setUp() {
    rule = BlocClassModifiers();

    newPackage('external_lib').addFile('lib/external_lib.dart', '''
class ExternalEvent {}
class ExternalState {}
''');

    super.setUp();
  }

  Future<void> test_bloc_related_classes() async {
    await assertDiagnosticsInRanges('''
import 'package:bloc/bloc.dart';

class /*[0*/MyState/*0]*/ {}
class /*[1*/MyStateInitial/*1]*/ extends MyState {}
class /*[2*/MyEvent/*2]*/ {}

class MyBloc extends Bloc<MyEvent, MyState> {
  MyBloc() : super(MyStateInitial());
}
''');
  }

  Future<void> test_cubit_state_without_subclasses() async {
    await assertDiagnosticsInRanges('''
import 'package:bloc/bloc.dart';

class [!MyState!] {}

class MyCubit extends Cubit<MyState> {
  MyCubit() : super(MyState());
}
''');
  }

  Future<void> test_nested_hierarchy() async {
    await assertDiagnosticsInRanges('''
import 'package:bloc/bloc.dart';

class /*[0*/MyState/*0]*/ {}
class /*[1*/MyStateLoaded/*1]*/ extends MyState {}
class /*[2*/MyStateLoadedSuccess/*2]*/ extends MyStateLoaded {}
final class MyEvent {}

class MyBloc extends Bloc<MyEvent, MyState> {
  MyBloc() : super(MyStateLoadedSuccess());
}
''');
  }

  Future<void> test_presentation_events() async {
    await assertDiagnosticsInRanges('''
import 'package:bloc/bloc.dart';
import 'package:bloc_presentation/bloc_presentation.dart';

final class MyState {}
class /*[0*/MyPresentationEvent/*0]*/ {}
class /*[1*/MyPresentationEventSuccess/*1]*/ extends MyPresentationEvent {}

class MyCubit extends Cubit<MyState>
    with BlocPresentationMixin<MyState, MyPresentationEvent> {
  MyCubit() : super(MyState());
}
''');
  }

  Future<void> test_subclasses_in_parts_count_as_same_library() async {
    newFile('$testPackageLibPath/states.dart', '''
part of 'test.dart';

final class MyStateInitial extends MyState {}
''');

    await assertDiagnosticsInRanges('''
import 'package:bloc/bloc.dart';

part 'states.dart';

class [!MyState!] {}
final class MyEvent {}

class MyBloc extends Bloc<MyEvent, MyState> {
  MyBloc() : super(MyStateInitial());
}
''');
  }

  Future<void> test_no_diagnostics_when_correctly_modified() async {
    await assertNoDiagnostics('''
import 'package:bloc/bloc.dart';
import 'package:bloc_presentation/bloc_presentation.dart';

sealed class MyState {}
final class MyStateInitial extends MyState {}
sealed class MyEvent {}
final class MyEventLoad extends MyEvent {}
sealed class MyPresentationEvent {}
final class MyPresentationEventSuccess extends MyPresentationEvent {}

class MyBloc extends Bloc<MyEvent, MyState>
    with BlocPresentationMixin<MyState, MyPresentationEvent> {
  MyBloc() : super(MyStateInitial());
}
''');
  }

  Future<void> test_generic_types_ignored() async {
    await assertNoDiagnostics('''
import 'package:bloc/bloc.dart';

class MyCubit<T> extends Cubit<T> {
  MyCubit(super.initialState);
}

class MyBloc<E, S> extends Bloc<E, S> {
  MyBloc(super.initialState);
}
''');
  }

  Future<void> test_external_classes_ignored() async {
    await assertNoDiagnostics('''
import 'package:bloc/bloc.dart';
import 'package:external_lib/external_lib.dart';

class MyBloc extends Bloc<ExternalEvent, ExternalState> {
  MyBloc() : super(ExternalState());
}
''');
  }
}
