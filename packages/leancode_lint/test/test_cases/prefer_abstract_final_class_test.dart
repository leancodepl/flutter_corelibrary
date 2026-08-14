import 'package:analyzer_testing/analysis_rule/analysis_rule.dart';
import 'package:leancode_lint/src/lints/prefer_abstract_final_class.dart';
import 'package:test_reflective_loader/test_reflective_loader.dart';

import '../assert_ranges.dart';

void main() {
  defineReflectiveSuite(() {
    defineReflectiveTests(PreferAbstractFinalClassTest);
  });
}

@reflectiveTest
class PreferAbstractFinalClassTest extends AnalysisRuleTest {
  @override
  void setUp() {
    rule = PreferAbstractFinalClass();

    super.setUp();
  }

  Future<void>
  test_static_holder_with_empty_arrow_constructor_is_marked() async {
    await assertDiagnosticsInRanges('''
class [!MyConstants!] {
  MyConstants._();
  static const foo = 1;
}
''');
  }

  Future<void>
  test_static_holder_with_empty_block_constructor_is_marked() async {
    await assertDiagnosticsInRanges('''
class [!MyConstants!] {
  MyConstants._() {}
  static const foo = 1;
}
''');
  }

  Future<void> test_static_holder_with_static_method_is_marked() async {
    await assertDiagnosticsInRanges('''
class [!Helpers!] {
  Helpers._();
  static int add(int a, int b) => a + b;
}
''');
  }

  Future<void> test_const_private_constructor_is_marked() async {
    await assertDiagnosticsInRanges('''
class [!MyConstants!] {
  const MyConstants._();
  static const foo = 1;
}
''');
  }

  Future<void> test_factory_constructor_is_not_marked() async {
    await assertNoDiagnostics('''
class MyConstants {
  MyConstants._();
  factory MyConstants.create() => MyConstants._();
  static const foo = 1;
}
''');
  }

  Future<void> test_additional_named_constructor_is_not_marked() async {
    await assertNoDiagnostics('''
class MyConstants {
  MyConstants._();
  MyConstants.named();
  static const foo = 1;
}
''');
  }

  Future<void> test_additional_public_constructor_is_not_marked() async {
    await assertNoDiagnostics('''
class MyConstants {
  MyConstants();
  static const foo = 1;
}
''');
  }

  Future<void> test_private_constructor_with_parameters_is_not_marked() async {
    await assertNoDiagnostics('''
class MyConstants {
  MyConstants._(int value);
  static const foo = 1;
}
''');
  }

  Future<void> test_private_constructor_with_body_is_not_marked() async {
    await assertNoDiagnostics('''
class MyConstants {
  MyConstants._() {
    print('hello');
  }
  static const foo = 1;
}
''');
  }

  Future<void> test_private_constructor_with_initializer_is_not_marked() async {
    await assertNoDiagnostics('''
class MyConstants {
  final int value;
  MyConstants._() : value = 1;
  static const foo = 1;
}
''');
  }

  Future<void> test_instance_field_is_not_marked() async {
    await assertNoDiagnostics('''
class MyConstants {
  MyConstants._();
  final int value = 1;
  static const foo = 1;
}
''');
  }

  Future<void> test_instance_method_is_not_marked() async {
    await assertNoDiagnostics('''
class MyConstants {
  MyConstants._();
  void doSomething() {}
  static const foo = 1;
}
''');
  }

  Future<void> test_instance_getter_is_not_marked() async {
    await assertNoDiagnostics('''
class MyConstants {
  MyConstants._();
  int get value => 1;
  static const foo = 1;
}
''');
  }

  Future<void> test_already_abstract_final_is_not_marked() async {
    await assertNoDiagnostics('''
abstract final class MyConstants {
  static const foo = 1;
}
''');
  }

  Future<void> test_already_final_is_not_marked() async {
    await assertNoDiagnostics('''
final class MyConstants {
  MyConstants._();
  static const foo = 1;
}
''');
  }

  Future<void> test_sealed_class_is_not_marked() async {
    await assertNoDiagnostics('''
sealed class MyConstants {
  MyConstants._();
  static const foo = 1;
}
''');
  }

  Future<void> test_class_extending_another_is_not_marked() async {
    await assertNoDiagnostics('''
class Base {}

class MyConstants extends Base {
  MyConstants._();
  static const foo = 1;
}
''');
  }

  Future<void> test_class_implementing_interface_is_not_marked() async {
    await assertNoDiagnostics('''
class Base {}

class MyConstants implements Base {
  MyConstants._();
  static const foo = 1;
}
''');
  }

  Future<void> test_class_with_mixin_is_not_marked() async {
    await assertNoDiagnostics('''
mixin SomeMixin {}

class MyConstants with SomeMixin {
  MyConstants._();
  static const foo = 1;
}
''');
  }

  Future<void>
  test_normal_class_with_public_constructor_and_statics_is_not_marked() async {
    await assertNoDiagnostics('''
class Counter {
  Counter(this.start);
  final int start;
  static const zero = 0;
}
''');
  }

  Future<void> test_class_without_static_members_is_not_marked() async {
    await assertNoDiagnostics('''
class MyConstants {
  MyConstants._();
}
''');
  }

  Future<void> test_enum_is_not_marked() async {
    await assertNoDiagnostics('''
enum MyEnum {
  a,
  b;

  static const foo = 1;
}
''');
  }

  Future<void> test_mixin_declaration_is_not_marked() async {
    await assertNoDiagnostics('''
mixin MyMixin {
  static const foo = 1;
}
''');
  }

  Future<void> test_private_primary_constructor_guard_is_marked() async {
    await assertDiagnosticsInRanges('''
class [!MyConstants!]._() {
  static const foo = 1;
}
''');
  }

  Future<void> test_const_private_primary_constructor_guard_is_marked() async {
    await assertDiagnosticsInRanges('''
class const [!MyConstants!]._() {
  static const foo = 1;
}
''');
  }

  Future<void> test_unnamed_primary_constructor_is_not_marked() async {
    await assertNoDiagnostics('''
class MyConstants() {
  static const foo = 1;
}
''');
  }

  Future<void>
  test_primary_constructor_guard_with_parameters_is_not_marked() async {
    await assertNoDiagnostics('''
class MyConstants._(final int x) {
  static const foo = 1;
}
''');
  }

  Future<void> test_primary_constructor_guard_with_body_is_not_marked() async {
    await assertNoDiagnostics('''
class MyConstants._() {
  this {
    print(1);
  }

  static const foo = 1;
}
''');
  }

  Future<void>
  test_primary_constructor_guard_with_additional_constructor_is_not_marked() async {
    await assertNoDiagnostics('''
class MyConstants._() {
  factory create() => MyConstants._();
  static const foo = 1;
}
''');
  }
}
