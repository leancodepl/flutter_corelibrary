import 'package:analyzer_testing/analysis_rule/analysis_rule.dart';
import 'package:leancode_lint/lints/add_cubit_suffix_for_cubits.dart';
import 'package:test_reflective_loader/test_reflective_loader.dart';

import 'mock_libraries.dart';

void main() {
  defineReflectiveSuite(() {
    defineReflectiveTests(AddCubitSuffixForYourCubitsTest);
  });
}

@reflectiveTest
class AddCubitSuffixForYourCubitsTest extends AnalysisRuleTest {
  @override
  void setUp() {
    rule = AddCubitSuffixForYourCubits();
    super.setUp();

    addMocks([MockLibrary.bloc, MockLibrary.flutterBloc]);
  }

  Future<void> test_main() async {
    await assertDiagnostics(
      '''
import 'package:flutter_bloc/flutter_bloc.dart';

class ProperlyNamedCubit extends Cubit<bool> {
  ProperlyNamedCubit() : super(true);
}

class NotProperlyNamed extends Cubit<bool> {
  NotProperlyNamed() : super(true);
}

class NotProperlyNamedWithDifferentSuperClass extends ProperlyNamedCubit {
  NotProperlyNamedWithDifferentSuperClass();
}

class ProperlyNamedWithDifferentSuperClassCubit extends ProperlyNamedCubit {
  ProperlyNamedWithDifferentSuperClassCubit();
}

class ClassExtendingOtherCubitClassWithoutSuffix extends NotProperlyNamed {
  ClassExtendingOtherCubitClassWithoutSuffix();
}
''',
      [lint(144, 16), lint(228, 39), lint(478, 42)],
    );
  }
}
