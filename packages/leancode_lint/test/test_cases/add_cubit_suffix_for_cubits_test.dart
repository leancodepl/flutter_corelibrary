import 'package:analyzer_testing/analysis_rule/analysis_rule.dart';
import 'package:leancode_lint/lints/add_cubit_suffix_for_cubits.dart';
import 'package:test_reflective_loader/test_reflective_loader.dart';

import '../assert_ranges.dart';
import '../mock_libraries.dart';

void main() {
  defineReflectiveSuite(() {
    defineReflectiveTests(AddCubitSuffixForYourCubitsTest);
  });
}

@reflectiveTest
class AddCubitSuffixForYourCubitsTest extends AnalysisRuleTest
    with MockBloc, MockFlutterBloc {
  @override
  void setUp() {
    rule = AddCubitSuffixForYourCubits();

    super.setUp();
  }

  Future<void> test_main() async {
    await assertDiagnosticsInRanges('''
import 'package:flutter_bloc/flutter_bloc.dart';

class ProperlyNamedCubit extends Cubit<bool> {
  ProperlyNamedCubit() : super(true);
}

class /*[0*/NotProperlyNamed/*0]*/ extends Cubit<bool> {
  NotProperlyNamed() : super(true);
}

class /*[1*/NotProperlyNamedWithDifferentSuperClass/*1]*/ extends ProperlyNamedCubit {
  NotProperlyNamedWithDifferentSuperClass();
}

class ProperlyNamedWithDifferentSuperClassCubit extends ProperlyNamedCubit {
  ProperlyNamedWithDifferentSuperClassCubit();
}

class /*[2*/ClassExtendingOtherCubitClassWithoutSuffix/*2]*/ extends NotProperlyNamed {
  ClassExtendingOtherCubitClassWithoutSuffix();
}
''');
  }
}
