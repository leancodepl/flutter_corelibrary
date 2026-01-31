part of '../mock_libraries.dart';

mixin MockFlutterBloc on AnalysisRuleTest {
  @override
  void setUp() {
    newPackage('flutter_bloc').addFile('lib/flutter_bloc.dart', '''
export 'package:bloc/bloc.dart';
''');
    super.setUp();
  }
}
