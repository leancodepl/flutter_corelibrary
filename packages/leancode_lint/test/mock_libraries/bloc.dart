part of '../mock_libraries.dart';

mixin MockBloc on AnalysisRuleTest {
  @override
  void setUp() {
    newPackage('bloc').addFile('lib/bloc.dart', '''
abstract class Cubit<State> extends BlocBase<State> {
  Cubit(State initialState) : super(initialState);
}
''');
    super.setUp();
  }
}
