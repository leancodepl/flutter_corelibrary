import 'package:analyzer_testing/analysis_rule/analysis_rule.dart';
import 'package:leancode_lint/config.dart';
import 'package:leancode_lint/src/lints/bloc_related_class_naming.dart';
import 'package:test_reflective_loader/test_reflective_loader.dart';

import '../assert_ranges.dart';
import '../mock_libraries.dart';

void main() {
  defineReflectiveSuite(() {
    defineReflectiveTests(BlocRelatedClassNamingTest);
    defineReflectiveTests(BlocRelatedClassNamingCustomSuffixesTest);
  });
}

@reflectiveTest
class BlocRelatedClassNamingTest extends AnalysisRuleTest
    with MockBloc, MockBlocPresentation, MockFlutterBloc {
  @override
  void setUp() {
    rule = BlocRelatedClassNaming();

    newPackage('external_lib').addFile('lib/external_lib.dart', '''
class ExternalWrongEvent {}
class ExternalWrongState {}
''');

    super.setUp();
  }

  Future<void> test_bloc() async {
    await assertDiagnosticsInRanges('''
import 'package:bloc/bloc.dart';
import 'package:bloc_presentation/bloc_presentation.dart';

class GoodEvent {}
class GoodState {}
class GoodPresentationEvent {}

class GoodBloc extends Bloc<GoodEvent, GoodState>
    with BlocPresentationMixin<GoodState, GoodPresentationEvent> {
  GoodBloc() : super(GoodState());
}

class /*[0*/WrongEvent/*0]*/ {}
class /*[1*/WrongState/*1]*/ {}
class /*[2*/WrongPresentationEvent/*2]*/ {}

class MyBloc extends Bloc<WrongEvent, WrongState>
    with BlocPresentationMixin<WrongState, WrongPresentationEvent> {
  MyBloc() : super(WrongState());
}
''');
  }

  Future<void> test_cubit() async {
    await assertDiagnosticsInRanges('''
import 'package:bloc/bloc.dart';
import 'package:bloc_presentation/bloc_presentation.dart';

class GoodState {}
class GoodPresentationEvent {}

class GoodCubit extends Cubit<GoodState>
    with BlocPresentationMixin<GoodState, GoodPresentationEvent> {
  GoodCubit() : super(GoodState());
}

class /*[0*/WrongState/*0]*/ {}
class /*[1*/WrongPresentationEvent/*1]*/ {}

class MyCubit extends Cubit<WrongState>
    with BlocPresentationMixin<WrongState, WrongPresentationEvent> {
  MyCubit() : super(WrongState());
}
''');
  }

  Future<void> test_external_classes_ignored() async {
    await assertNoDiagnostics('''
import 'package:bloc/bloc.dart';
import 'package:external_lib/external_lib.dart';

class MyBloc extends Bloc<ExternalWrongEvent, ExternalWrongState> {
  MyBloc() : super(ExternalWrongState());
}
''');
  }

  Future<void> test_part_file_definition() async {
    newFile('$testPackageLibPath/part.dart', '''
part of 'test.dart';

class WrongState {}

class GoodState {}
''');

    await assertDiagnosticsInRanges('''
import 'package:bloc/bloc.dart';

part 'part.dart';

class MyCubit extends Cubit</*[0*/WrongState/*0]*/> {
  MyCubit() : super(WrongState());
}

class GoodCubit extends Cubit<GoodState> {
  GoodCubit() : super(GoodState());
}
''');
  }
}

@reflectiveTest
class BlocRelatedClassNamingCustomSuffixesTest extends AnalysisRuleTest
    with MockBloc, MockBlocPresentation, MockFlutterBloc {
  @override
  void setUp() {
    rule = BlocRelatedClassNaming(
      config: const BlocRelatedClassNamingConfig(
        stateSuffix: 'Foobar',
        eventSuffix: 'Cmd',
        presentationEventSuffix: 'Output',
      ),
    );
    super.setUp();
  }

  Future<void> test_bloc_custom_suffixes() async {
    await assertDiagnosticsInRanges('''
import 'package:bloc/bloc.dart';
import 'package:bloc_presentation/bloc_presentation.dart';

class GoodCmd {}
class GoodFoobar {}
class GoodOutput {}

class GoodBloc extends Bloc<GoodCmd, GoodFoobar>
    with BlocPresentationMixin<GoodFoobar, GoodOutput> {
  GoodBloc() : super(GoodFoobar());
}

class /*[0*/WrongCmd/*0]*/ {}
class /*[1*/WrongFoobar/*1]*/ {}
class /*[2*/WrongOutput/*2]*/ {}

class MyBloc extends Bloc<WrongCmd, WrongFoobar>
    with BlocPresentationMixin<WrongFoobar, WrongOutput> {
  MyBloc() : super(WrongFoobar());
}
''');
  }

  Future<void> test_cubit_custom_suffixes() async {
    await assertDiagnosticsInRanges('''
import 'package:bloc/bloc.dart';
import 'package:bloc_presentation/bloc_presentation.dart';

class GoodFoobar {}
class GoodOutput {}

class GoodCubit extends Cubit<GoodFoobar>
    with BlocPresentationMixin<GoodFoobar, GoodOutput> {
  GoodCubit() : super(GoodFoobar());
}

class /*[0*/WrongFoobar/*0]*/ {}
class /*[1*/WrongOutput/*1]*/ {}

class MyCubit extends Cubit<WrongFoobar>
    with BlocPresentationMixin<WrongFoobar, WrongOutput> {
  MyCubit() : super(WrongFoobar());
}
''');
  }
}
