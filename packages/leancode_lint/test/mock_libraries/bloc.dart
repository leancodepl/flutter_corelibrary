part of '../mock_libraries.dart';

mixin MockBloc on AnalysisRuleTest {
  @override
  void setUp() {
    newPackage('bloc').addFile('lib/bloc.dart', '''
class BlocBase<State> {
  BlocBase(this.state);
  State state;
}

abstract class Cubit<State> extends BlocBase<State> {
  Cubit(State initialState) : super(initialState);
}

abstract class Bloc<Event, State> extends BlocBase<State> {
  Bloc(State initialState) : super(initialState);
}
''');
    super.setUp();
  }
}
