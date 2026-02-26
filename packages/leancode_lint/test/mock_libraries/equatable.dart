part of '../mock_libraries.dart';

mixin MockEquatable on AnalysisRuleTest {
  @override
  void setUp() {
    newPackage('equatable').addFile('lib/equatable.dart', '''
class Equatable {
  const Equatable();
  List<Object?> get props;
}

mixin EquatableMixin {
  List<Object?> get props;
}
''');
    super.setUp();
  }
}
