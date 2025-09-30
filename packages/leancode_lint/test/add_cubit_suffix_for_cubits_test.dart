import 'package:analyzer/src/lint/registry.dart';
import 'package:analyzer/utilities/package_config_file_builder.dart';
import 'package:analyzer_testing/analysis_rule/analysis_rule.dart';
import 'package:leancode_lint/lints/add_cubit_suffix_for_cubits.dart';
import 'package:test_reflective_loader/test_reflective_loader.dart';

void main() {
  defineReflectiveSuite(() {
    defineReflectiveTests(AddCubitSuffixForYourCubitsTest);
  });
}

@reflectiveTest
class AddCubitSuffixForYourCubitsTest extends AnalysisRuleTest {
  final rule = AddCubitSuffixForYourCubits();

  @override
  void setUp() {
    Registry.ruleRegistry.registerWarningRule(rule);
    super.setUp();

    const blocPath = '/packages/bloc';
    newFile('$blocPath/lib/bloc.dart', '''
abstract class Cubit<State> extends BlocBase<State> {
  Cubit(State initialState) : super(initialState);
}
''');

    const flutterBlocPath = '/packages/flutter_bloc';
    newFile('$flutterBlocPath/lib/flutter_bloc.dart', '''
export 'package:bloc/bloc.dart';
''');

    writeTestPackageConfig(
      PackageConfigFileBuilder()
        ..add(name: 'bloc', rootPath: convertPath(blocPath))
        ..add(name: 'flutter_bloc', rootPath: convertPath(flutterBlocPath)),
    );
  }

  @override
  String get analysisRule => rule.name;

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
