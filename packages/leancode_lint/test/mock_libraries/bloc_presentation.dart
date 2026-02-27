part of '../mock_libraries.dart';

mixin MockBlocPresentation on AnalysisRuleTest {
  @override
  void setUp() {
    newPackage('bloc_presentation').addFile('lib/bloc_presentation.dart', '''
mixin BlocPresentationMixin<State, PresentationEvent> {}
''');
    super.setUp();
  }
}
