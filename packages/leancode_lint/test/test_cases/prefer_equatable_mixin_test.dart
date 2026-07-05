import 'package:analyzer_testing/analysis_rule/analysis_rule.dart';
import 'package:leancode_lint/src/lints/prefer_equatable_mixin.dart';
import 'package:test_reflective_loader/test_reflective_loader.dart';

import '../assert_ranges.dart';
import '../mock_libraries.dart';

void main() {
  defineReflectiveSuite(() {
    defineReflectiveTests(PreferEquatableMixinTest);
    defineReflectiveTests(PreferEquatableMixinWithOldEquatableTest);
  });
}

@reflectiveTest
class PreferEquatableMixinTest extends AnalysisRuleTest with MockEquatable {
  @override
  void setUp() {
    rule = PreferEquatableMixin();

    super.setUp();
  }

  Future<void> test_only_directly_extending_equatable() async {
    await assertDiagnosticsInRanges('''
import 'package:equatable/equatable.dart';

class MyState extends [!Equatable!] {
  @override
  List<Object?> get props => [];
}

class MyState2 extends MyState {
  @override
  List<Object?> get props => [];
}
''');
  }

  Future<void> test_mixin_not_flagged() async {
    await assertNoDiagnostics('''
import 'package:equatable/equatable.dart';

class MyState3 with Equatable {
  @override
  List<Object?> get props => [];
}
''');
  }

  Future<void> test_deprecated_equatable_mixin_still_legal() async {
    await assertNoDiagnostics('''
import 'package:equatable/equatable.dart';

// ignore: deprecated_member_use
class MyState3 with EquatableMixin {
  @override
  List<Object?> get props => [];
}
''');
  }

  Future<void> test_with_other_mixins() async {
    await assertDiagnosticsInRanges('''
import 'package:equatable/equatable.dart';

mixin SomethingElse {}

class MyState extends [!Equatable!] with SomethingElse {
  @override
  List<Object?> get props => [];
}

class MyState2 extends MyState with SomethingElse {
  @override
  List<Object?> get props => [];
}

class MyState3 with SomethingElse, Equatable {
  @override
  List<Object?> get props => [];
}
''');
  }

  Future<void> test_recommends_equatable() async {
    await assertDiagnosticsInRanges(
      '''
import 'package:equatable/equatable.dart';

class MyState extends [!Equatable!] {
  @override
  List<Object?> get props => [];
}
''',
      messageContainsAll: const [
        ['mix in Equatable instead'],
      ],
    );
  }
}

/// Tests the behavior with `equatable` older than 2.1.0, where `Equatable`
/// cannot be used as a mixin and `EquatableMixin` should be used instead.
@reflectiveTest
class PreferEquatableMixinWithOldEquatableTest extends AnalysisRuleTest
    with MockOldEquatable {
  @override
  void setUp() {
    rule = PreferEquatableMixin();

    super.setUp();
  }

  Future<void> test_only_directly_extending_equatable() async {
    await assertDiagnosticsInRanges('''
import 'package:equatable/equatable.dart';

class MyState extends [!Equatable!] {
  @override
  List<Object?> get props => [];
}

class MyState2 extends MyState {
  @override
  List<Object?> get props => [];
}
''');
  }

  Future<void> test_mixin_not_flagged() async {
    await assertNoDiagnostics('''
import 'package:equatable/equatable.dart';

class MyState3 with EquatableMixin {
  @override
  List<Object?> get props => [];
}
''');
  }

  Future<void> test_recommends_equatable_mixin() async {
    await assertDiagnosticsInRanges(
      '''
import 'package:equatable/equatable.dart';

class MyState extends [!Equatable!] {
  @override
  List<Object?> get props => [];
}
''',
      messageContainsAll: const [
        ['mix in EquatableMixin instead'],
      ],
    );
  }
}
