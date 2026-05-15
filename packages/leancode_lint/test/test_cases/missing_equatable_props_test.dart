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

class MyState with EquatableMixin {
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

class MyState with EquatableMixin {
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

class MyState with EquatableMixin {
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

class MyState with EquatableMixin {
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

class MyState with EquatableMixin {
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

class MyState with EquatableMixin {
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

class MyState with EquatableMixin {
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

class Parent with EquatableMixin {
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

class Parent with EquatableMixin {
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

class Parent with EquatableMixin {
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

  Future<void> test_super_props_not_suggested_for_direct_equatable_subclass() async {
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

  Future<void> test_unrecognized_spread_skips_lint() async {
    await assertNoDiagnostics('''
import 'package:equatable/equatable.dart';

class MyState with EquatableMixin {
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

class MyState with EquatableMixin {
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
