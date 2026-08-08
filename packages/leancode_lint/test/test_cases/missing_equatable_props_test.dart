import 'package:analyzer_testing/analysis_rule/analysis_rule.dart';
import 'package:leancode_lint/src/lints/missing_equatable_props.dart';
import 'package:test_reflective_loader/test_reflective_loader.dart';

import '../assert_ranges.dart';
import '../mock_libraries.dart';

void main() {
  defineReflectiveSuite(() {
    defineReflectiveTests(MissingEquatablePropsTest);
  });
}

@reflectiveTest
class MissingEquatablePropsTest extends AnalysisRuleTest with MockEquatable {
  @override
  void setUp() {
    rule = MissingEquatableProps();

    super.setUp();
  }

  Future<void> test_all_fields_present() async {
    await assertNoDiagnostics('''
import 'package:equatable/equatable.dart';

class MyState with Equatable {
  MyState(this.a, this.b);

  final int a;
  final String b;

  @override
  List<Object?> get props => [a, b];
}
''');
  }

  Future<void> test_missing_fields_in_mixin_class() async {
    await assertDiagnosticsInRanges('''
import 'package:equatable/equatable.dart';

class MyState with Equatable {
  MyState(this.a, this.b, this.c);

  final int a;
  final String b;
  final double c;

  @override
  List<Object?> get props => /*[0*/[a]/*0]*/;
}
''');
  }

  Future<void> test_missing_fields_in_deprecated_mixin_class() async {
    await assertDiagnosticsInRanges('''
import 'package:equatable/equatable.dart';

// ignore: deprecated_member_use
class MyState with EquatableMixin {
  MyState(this.a, this.b, this.c);

  final int a;
  final String b;
  final double c;

  @override
  List<Object?> get props => /*[0*/[a]/*0]*/;
}
''');
  }

  Future<void> test_missing_fields_in_equatable_subclass() async {
    await assertDiagnosticsInRanges('''
import 'package:equatable/equatable.dart';

class MyState extends Equatable {
  MyState(this.a, this.b);

  final int a;
  final String b;

  @override
  List<Object?> get props => /*[0*/[]/*0]*/;
}
''');
  }

  Future<void> test_static_fields_ignored() async {
    await assertNoDiagnostics('''
import 'package:equatable/equatable.dart';

class MyState with Equatable {
  MyState(this.a);

  static const int unused = 0;
  final int a;

  @override
  List<Object?> get props => [a];
}
''');
  }

  Future<void> test_getters_ignored() async {
    await assertNoDiagnostics('''
import 'package:equatable/equatable.dart';

class MyState with Equatable {
  MyState(this.a);

  final int a;
  int get doubled => a * 2;

  @override
  List<Object?> get props => [a];
}
''');
  }

  Future<void> test_block_body_props_getter() async {
    await assertDiagnosticsInRanges('''
import 'package:equatable/equatable.dart';

class MyState with Equatable {
  MyState(this.a, this.b);

  final int a;
  final int b;

  @override
  List<Object?> get props {
    return /*[0*/[a]/*0]*/;
  }
}
''');
  }

  Future<void> test_non_equatable_class_skipped() async {
    await assertNoDiagnostics('''
class Plain {
  Plain(this.a);

  final int a;

  List<Object?> get props => [];
}
''');
  }

  Future<void> test_multiple_variables_in_one_declaration() async {
    await assertDiagnosticsInRanges('''
import 'package:equatable/equatable.dart';

class MyState with Equatable {
  MyState(this.a, this.b);

  final int a, b;

  @override
  List<Object?> get props => /*[0*/[a]/*0]*/;
}
''');
  }

  Future<void> test_function_typed_fields_are_required() async {
    await assertDiagnosticsInRanges('''
import 'package:equatable/equatable.dart';

class MyState with Equatable {
  MyState(this.a, this.onTap);

  final int a;
  final void Function() onTap;

  @override
  List<Object?> get props => /*[0*/[a]/*0]*/;
}
''');
  }

  Future<void> test_this_qualified_references_are_recognized() async {
    await assertNoDiagnostics('''
import 'package:equatable/equatable.dart';

class MyState with Equatable {
  MyState(this.a, this.b);

  final int a;
  final int b;

  @override
  List<Object?> get props => [this.a, this.b];
}
''');
  }

  Future<void> test_super_props_required_when_parent_is_equatable() async {
    await assertDiagnosticsInRanges('''
import 'package:equatable/equatable.dart';

class Parent with Equatable {
  Parent(this.a);

  final int a;

  @override
  List<Object?> get props => [a];
}

class Sub extends Parent {
  Sub(super.a, this.b);

  final int b;

  @override
  List<Object?> get props => /*[0*/[b]/*0]*/;
}
''');
  }

  Future<void> test_super_props_recognized_when_present_as_spread() async {
    await assertNoDiagnostics('''
import 'package:equatable/equatable.dart';

class Parent with Equatable {
  Parent(this.a);

  final int a;

  @override
  List<Object?> get props => [a];
}

class Sub extends Parent {
  Sub(super.a, this.b);

  final int b;

  @override
  List<Object?> get props => [...super.props, b];
}
''');
  }

  Future<void> test_super_props_recognized_when_present_without_spread() async {
    await assertNoDiagnostics('''
import 'package:equatable/equatable.dart';

class Parent with Equatable {
  Parent(this.a);

  final int a;

  @override
  List<Object?> get props => [a];
}

class Sub extends Parent {
  Sub(super.a, this.b);

  final int b;

  @override
  List<Object?> get props => [super.props, b];
}
''');
  }

  Future<void>
  test_super_props_not_suggested_for_direct_equatable_subclass() async {
    await assertDiagnosticsInRanges('''
import 'package:equatable/equatable.dart';

class MyState extends Equatable {
  const MyState(this.a, this.b);

  final int a;
  final int b;

  @override
  List<Object?> get props => /*[0*/[a]/*0]*/;
}
''');
  }

  Future<void>
  test_super_props_not_suggested_when_parent_has_no_concrete_props() async {
    await assertDiagnosticsInRanges('''
import 'package:equatable/equatable.dart';

abstract class AbstractBase extends Equatable {
  const AbstractBase();
}

class Sub extends AbstractBase {
  const Sub(this.a, this.b);

  final int a;
  final int b;

  @override
  List<Object?> get props => /*[0*/[a]/*0]*/;
}
''');
  }

  Future<void>
  test_no_diagnostic_when_parent_has_no_concrete_props_and_all_fields_listed() async {
    await assertNoDiagnostics('''
import 'package:equatable/equatable.dart';

abstract class AbstractBase extends Equatable {
  const AbstractBase();
}

class Sub extends AbstractBase {
  const Sub(this.a, this.b);

  final int a;
  final int b;

  @override
  List<Object?> get props => [a, b];
}
''');
  }

  Future<void>
  test_super_props_suggested_when_abstract_parent_has_concrete_props() async {
    await assertDiagnosticsInRanges('''
import 'package:equatable/equatable.dart';

abstract class AbstractBase extends Equatable {
  const AbstractBase(this.shared);

  final int shared;

  @override
  List<Object?> get props => [shared];
}

class Sub extends AbstractBase {
  const Sub(super.shared, this.b);

  final int b;

  @override
  List<Object?> get props => /*[0*/[b]/*0]*/;
}
''');
  }

  Future<void>
  test_super_props_not_suggested_when_parent_props_is_empty() async {
    await assertNoDiagnostics('''
import 'package:equatable/equatable.dart';

class Parent with Equatable {
  const Parent();

  @override
  List<Object?> get props => [];
}

class Sub extends Parent {
  const Sub(this.a);

  final int a;

  @override
  List<Object?> get props => [a];
}
''');
  }

  Future<void>
  test_super_props_not_suggested_when_whole_parent_chain_has_no_fields() async {
    await assertDiagnosticsInRanges('''
import 'package:equatable/equatable.dart';

class Base with Equatable {
  const Base();

  @override
  List<Object?> get props => [];
}

class Middle extends Base {
  const Middle();
}

class Sub extends Middle {
  const Sub(this.a, this.b);

  final int a;
  final int b;

  @override
  List<Object?> get props => [![a]!];
}
''');
  }

  Future<void>
  test_super_props_suggested_when_grandparent_declares_fields() async {
    await assertDiagnosticsInRanges('''
import 'package:equatable/equatable.dart';

class Base with Equatable {
  const Base(this.shared);

  final int shared;

  @override
  List<Object?> get props => [shared];
}

class Middle extends Base {
  const Middle(super.shared);
}

class Sub extends Middle {
  const Sub(super.shared, this.a);

  final int a;

  @override
  List<Object?> get props => [![a]!];
}
''');
  }

  Future<void>
  test_super_props_not_suggested_when_parent_only_declares_getters() async {
    await assertNoDiagnostics('''
import 'package:equatable/equatable.dart';

class Parent with Equatable {
  const Parent();

  int get computed => 1;

  @override
  List<Object?> get props => [];
}

class Sub extends Parent {
  const Sub(this.a);

  final int a;

  @override
  List<Object?> get props => [a];
}
''');
  }

  Future<void>
  test_super_props_not_suggested_when_parent_only_declares_static_fields() async {
    await assertNoDiagnostics('''
import 'package:equatable/equatable.dart';

class Parent with Equatable {
  const Parent();

  static const int constant = 0;

  @override
  List<Object?> get props => [];
}

class Sub extends Parent {
  const Sub(this.a);

  final int a;

  @override
  List<Object?> get props => [a];
}
''');
  }

  Future<void>
  test_super_props_suggested_when_parent_mixin_declares_fields() async {
    await assertDiagnosticsInRanges('''
import 'package:equatable/equatable.dart';

mixin SharedFields {
  final int shared = 0;
}

class Parent with Equatable, SharedFields {
  @override
  List<Object?> get props => [shared];
}

class Sub extends Parent {
  Sub(this.a);

  final int a;

  @override
  List<Object?> get props => [![a]!];
}
''');
  }

  Future<void> test_unrecognized_spread_skips_lint() async {
    await assertNoDiagnostics('''
import 'package:equatable/equatable.dart';

class MyState with Equatable {
  MyState(this.a, this.b);

  final int a;
  final int b;

  List<Object?> get _extraProps => [a, b];

  @override
  List<Object?> get props => [..._extraProps];
}
''');
  }

  Future<void> test_non_list_literal_body_skips_lint() async {
    await assertNoDiagnostics('''
import 'package:equatable/equatable.dart';

class MyState with Equatable {
  MyState(this.a, this.b);

  final int a;
  final int b;

  List<Object?> _buildProps() => [a, b];

  @override
  List<Object?> get props => _buildProps();
}
''');
  }
}
