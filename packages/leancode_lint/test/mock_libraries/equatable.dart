part of '../mock_libraries.dart';

/// Mocks `equatable` 2.1.0 or higher, where `Equatable` can be used as a mixin
/// and `EquatableMixin` is deprecated.
mixin MockEquatable on AnalysisRuleTest {
  @override
  void setUp() {
    newPackage('equatable').addFile('lib/equatable.dart', '''
abstract mixin class Equatable {
  const Equatable();
  List<Object?> get props;
}

@Deprecated('use Equatable as a mixin instead')
mixin EquatableMixin {
  List<Object?> get props;
}
''');
    super.setUp();
  }
}

/// Mocks `equatable` older than 2.1.0, where `Equatable` cannot be used as a
/// mixin and `EquatableMixin` should be used instead.
mixin MockOldEquatable on AnalysisRuleTest {
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
