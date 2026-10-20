/*
 * AI-Provenance:
 *   model: claude-fable-5-1
 *   harness: Claude Code
 */

import 'package:analyzer/src/diagnostic/diagnostic.dart' as diag;
import 'package:analyzer_testing/analysis_rule/analysis_rule.dart';
import 'package:leancode_lint/src/lints/avoid_shadowed_extension_members.dart';
import 'package:test_reflective_loader/test_reflective_loader.dart';

import '../assert_ranges.dart';

void main() {
  defineReflectiveSuite(() {
    defineReflectiveTests(AvoidShadowedExtensionMembersTest);
  });
}

@reflectiveTest
class AvoidShadowedExtensionMembersTest() extends AnalysisRuleTest {
  @override
  void setUp() {
    rule = AvoidShadowedExtensionMembers();

    super.setUp();
  }

  Future<void> test_method_shadowed_by_method_is_marked() async {
    await assertDiagnosticsInRanges(
      '''
class DateFormat {
  DateTime parse(String input) => DateTime.now();
  DateTime? tryParse(String input) => null;
}

extension DateFormatParsing on DateFormat {
  DateTime? [!tryParse!](String? input) => input == null ? null : parse(input);
  DateTime? parseOrNull(String? input) => input == null ? null : parse(input);
}
''',
      messageContainsAll: const [
        [
          "The extension method 'tryParse' is shadowed by the method 'DateFormat.tryParse', so it is only reachable through an explicit extension override.",
        ],
      ],
    );
  }

  Future<void> test_getter_shadowed_by_field_is_marked() async {
    await assertDiagnosticsInRanges(
      '''
class Point {
  Point(this.x);
  final int x;
}

extension PointX on Point {
  int get [!x!] => 0;
}
''',
      messageContainsAll: const [
        ["The extension getter 'x' is shadowed by the field 'Point.x'"],
      ],
    );
  }

  Future<void> test_getter_shadowed_by_getter_is_marked() async {
    await assertDiagnosticsInRanges(
      '''
class Point {
  int get x => 0;
}

extension PointX on Point {
  int get [!x!] => 1;
}
''',
      messageContainsAll: const [
        ["The extension getter 'x' is shadowed by the getter 'Point.x'"],
      ],
    );
  }

  Future<void> test_setter_shadowed_by_field_is_marked() async {
    await assertDiagnosticsInRanges(
      '''
class Point {
  int x = 0;
}

extension PointX on Point {
  set [!x!](int value) {}
}
''',
      messageContainsAll: const [
        ["The extension setter 'x' is shadowed by the field 'Point.x'"],
      ],
    );
  }

  Future<void> test_getter_shadowed_by_setter_is_marked() async {
    // `point.x` is an error rather than a call of the extension getter: the
    // instance setter alone takes the name.
    await assertDiagnosticsInRanges(
      '''
class Point {
  set x(int value) {}
}

extension PointX on Point {
  int get [!x!] => 0;
}
''',
      messageContainsAll: const [
        ["The extension getter 'x' is shadowed by the setter 'Point.x'"],
      ],
    );
  }

  Future<void> test_setter_shadowed_by_getter_is_marked() async {
    await assertDiagnosticsInRanges(
      '''
class Point {
  int get x => 0;
}

extension PointX on Point {
  set [!x!](int value) {}
}
''',
      messageContainsAll: const [
        ["The extension setter 'x' is shadowed by the getter 'Point.x'"],
      ],
    );
  }

  Future<void> test_getter_shadowed_by_method_is_marked() async {
    await assertDiagnosticsInRanges(
      '''
class Point {
  void reset() {}
}

extension PointX on Point {
  int get [!reset!] => 0;
}
''',
      messageContainsAll: const [
        ["The extension getter 'reset' is shadowed by the method 'Point.reset'"],
      ],
    );
  }

  Future<void> test_method_shadowed_by_getter_is_marked() async {
    await assertDiagnosticsInRanges(
      '''
class Point {
  int get x => 0;
}

extension PointX on Point {
  int [!x!]() => 0;
}
''',
      messageContainsAll: const [
        ["The extension method 'x' is shadowed by the getter 'Point.x'"],
      ],
    );
  }

  Future<void> test_operator_shadowed_by_operator_is_marked() async {
    await assertDiagnosticsInRanges(
      '''
class Point {
  Point operator +(Point other) => this;
  Point operator -() => this;
  int operator [](int index) => 0;
}

extension PointX on Point {
  Point operator /*[0*/+/*0]*/(Point other) => other;
  Point operator /*[1*/-/*1]*/() => this;
  int operator /*[2*/[]/*2]*/(int index) => 1;
  Point operator -(Point other) => other;
}
''',
      messageContainsAll: const [
        ["The extension operator '+' is shadowed by the operator 'Point.+'"],
        [
          "The extension operator 'unary-' is shadowed by the operator 'Point.unary-'",
        ],
        ["The extension operator '[]' is shadowed by the operator 'Point.[]'"],
      ],
    );
  }

  Future<void> test_member_inherited_from_superclass_shadows() async {
    await assertDiagnosticsInRanges(
      '''
class Shape {
  double get area => 0;
}

class Square extends Shape {}

extension SquareX on Square {
  double get [!area!] => 1;
}
''',
      messageContainsAll: const [
        ["is shadowed by the getter 'Shape.area'"],
      ],
    );
  }

  Future<void> test_abstract_member_of_interface_shadows() async {
    await assertDiagnosticsInRanges('''
abstract class Shape {
  double get area;
}

abstract class Square implements Shape {}

extension SquareX on Square {
  double get [!area!] => 1;
}
''');
  }

  Future<void> test_member_inherited_from_mixin_shadows() async {
    await assertDiagnosticsInRanges('''
mixin Measurable {
  double get area => 0;
}

class Square with Measurable {}

extension SquareX on Square {
  double get [!area!] => 1;
}
''');
  }

  Future<void> test_members_of_mixin_on_type_shadow() async {
    await assertDiagnosticsInRanges('''
class Shape {
  double get area => 0;
}

mixin Measurable on Shape {
  double get perimeter => 0;
}

extension MeasurableX on Measurable {
  double get /*[0*/area/*0]*/ => 1;
  double get /*[1*/perimeter/*1]*/ => 1;
}
''');
  }

  Future<void> test_enum_member_shadows() async {
    await assertDiagnosticsInRanges('''
enum Color { red, green }

extension ColorX on Color {
  int get [!index!] => 0;
}
''');
  }

  Future<void> test_extension_type_member_shadows() async {
    await assertDiagnosticsInRanges(
      '''
extension type Id(int value) {
  int get doubled => value * 2;
}

extension IdX on Id {
  int get /*[0*/value/*0]*/ => 0;
  int get /*[1*/doubled/*1]*/ => 0;
}
''',
      messageContainsAll: const [
        ["is shadowed by the field 'Id.value'"],
        ["is shadowed by the getter 'Id.doubled'"],
      ],
    );
  }

  Future<void> test_member_of_generic_on_type_shadows() async {
    await assertDiagnosticsInRanges(
      '''
extension IntListX on List<int> {
  void [!add!](int value) {}
}
''',
      messageContainsAll: const [
        ["is shadowed by the method 'List.add'"],
      ],
    );
  }

  Future<void> test_member_of_type_parameter_bound_shadows() async {
    await assertDiagnosticsInRanges(
      '''
extension NumX<T extends num> on T {
  T [!abs!]() => this;
}
''',
      messageContainsAll: const [
        ["is shadowed by the method 'num.abs'"],
      ],
    );
  }

  Future<void> test_private_member_of_the_same_library_shadows() async {
    await assertDiagnosticsInRanges('''
class Point {
  int get _x => 0;
}

extension PointX on Point {
  int get [!_x!] => 1;
}
''');
  }

  Future<void> test_new_member_is_not_marked() async {
    await assertNoDiagnostics('''
class DateFormat {
  DateTime parse(String input) => DateTime.now();
}

extension DateFormatParsing on DateFormat {
  DateTime? tryParse(String? input) => input == null ? null : parse(input);
}
''');
  }

  Future<void> test_member_of_subtype_does_not_shadow() async {
    await assertNoDiagnostics('''
class Shape {}

class Square extends Shape {
  double get area => 0;
}

extension ShapeX on Shape {
  double get area => 1;
}
''');
  }

  Future<void> test_static_member_of_on_type_does_not_shadow() async {
    await assertNoDiagnostics('''
class Point {
  static Point origin() => Point();
}

extension PointX on Point {
  Point origin() => this;
}
''');
  }

  Future<void> test_static_extension_member_is_not_marked() async {
    await assertNoDiagnostics('''
class Point {
  Point origin() => this;
}

extension PointX on Point {
  static Point origin() => Point();
}
''');
  }

  Future<void> test_private_member_of_another_library_does_not_shadow() async {
    newFile('$testPackageLibPath/point.dart', '''
class Point {
  int get _x => 0;
}
''');

    await assertNoDiagnostics('''
import 'point.dart';

extension PointX on Point {
  int get _x => 1;
}
''');
  }

  Future<void> test_unbounded_type_parameter_is_not_marked() async {
    await assertNoDiagnostics('''
extension AnyX<T> on T {
  T abs() => this;
}
''');
  }

  Future<void> test_nullable_on_type_is_not_marked() async {
    await assertNoDiagnostics('''
extension NullableStringX on String? {
  bool get isEmpty => this?.isEmpty ?? true;
}
''');
  }

  Future<void> test_function_on_type_is_not_marked() async {
    await assertNoDiagnostics('''
extension CallbackX on void Function() {
  void call() => this();
}
''');
  }

  Future<void> test_object_member_is_left_to_the_analyzer() async {
    const code = '''
class Point {}

extension PointX on Point {
  String toString() => 'Point';
}
''';

    await assertDiagnostics(code, [
      error(
        diag.extensionDeclaresMemberOfObject,
        code.indexOf('toString'),
        'toString'.length,
      ),
    ]);
  }

  Future<void> test_unresolved_on_type_is_not_marked() async {
    const code = '''
extension MissingX on Missing {
  int get x => 0;
}
''';

    await assertDiagnostics(code, [
      error(diag.undefinedClass, code.indexOf('Missing {'), 'Missing'.length),
    ]);
  }
}
