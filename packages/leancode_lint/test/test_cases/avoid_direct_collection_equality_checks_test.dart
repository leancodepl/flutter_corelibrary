import 'package:analyzer_testing/analysis_rule/analysis_rule.dart';
import 'package:leancode_lint/src/lints/avoid_direct_collection_equality_checks.dart';
import 'package:test_reflective_loader/test_reflective_loader.dart';

import '../assert_ranges.dart';

void main() {
  defineReflectiveSuite(() {
    defineReflectiveTests(AvoidDirectCollectionEqualityChecksTest);
  });
}

@reflectiveTest
class AvoidDirectCollectionEqualityChecksTest extends AnalysisRuleTest {
  @override
  void setUp() {
    rule = AvoidDirectCollectionEqualityChecks();

    super.setUp();
  }

  Future<void> test_list_equality_is_marked() async {
    await assertDiagnosticsInRanges('''
bool test(List<int> a, List<int> b) {
  return [!a == b!];
}
''');
  }

  Future<void> test_list_inequality_is_marked() async {
    await assertDiagnosticsInRanges('''
bool test(List<int> a, List<int> b) {
  return [!a != b!];
}
''');
  }

  Future<void> test_list_literals_are_marked() async {
    await assertDiagnosticsInRanges('''
bool test() {
  return [!<int>[1] == <int>[2]!];
}
''');
  }

  Future<void> test_set_equality_is_marked() async {
    await assertDiagnosticsInRanges('''
bool test(Set<int> a, Set<int> b) {
  return [!a == b!];
}
''');
  }

  Future<void> test_map_equality_is_marked() async {
    await assertDiagnosticsInRanges('''
bool test(Map<String, int> a, Map<String, int> b) {
  return [!a == b!];
}
''');
  }

  Future<void> test_nullable_lists_are_marked() async {
    await assertDiagnosticsInRanges('''
bool test(List<int>? a, List<int>? b) {
  return [!a == b!];
}
''');
  }

  Future<void> test_subtype_of_list_is_marked() async {
    await assertDiagnosticsInRanges('''
abstract class MyList implements List<int> {}

bool test(MyList a, List<int> b) {
  return [!a == b!];
}
''');
  }

  Future<void> test_local_map_variables_are_marked() async {
    await assertDiagnosticsInRanges('''
bool test() {
  final a = {'x': 1};
  final b = {'y': 2};
  return [!a == b!];
}
''');
  }

  Future<void> test_list_of_constructor_is_marked() async {
    await assertDiagnosticsInRanges('''
bool test() {
  final a = [1, 2, 3];
  final b = [1, 2, 3];
  return [!a == List.of(b)!];
}
''');
  }

  Future<void> test_to_list_conversion_is_marked() async {
    await assertDiagnosticsInRanges('''
bool test(List<int> a, Iterable<int> b) {
  return [!a == b.toList()!];
}
''');
  }

  Future<void> test_to_set_conversion_is_marked() async {
    await assertDiagnosticsInRanges('''
bool test(Set<int> a, Iterable<int> b) {
  return [!a == b.toSet()!];
}
''');
  }

  Future<void> test_comparison_with_null_is_not_marked() async {
    await assertNoDiagnostics('''
bool test(List<int>? a) {
  return a == null;
}
''');
  }

  Future<void> test_collection_vs_non_collection_is_not_marked() async {
    await assertNoDiagnostics('''
bool test(List<int> a, Object b) {
  return a == b;
}
''');
  }

  Future<void> test_scalar_comparison_is_not_marked() async {
    await assertNoDiagnostics('''
bool test(int a, int b, String c, String d) {
  return a == b && c == d;
}
''');
  }

  Future<void> test_different_collection_kinds_are_not_marked() async {
    await assertNoDiagnostics('''
bool test(List<int> a, Set<int> b) {
  return a == b;
}
''');
  }

  Future<void> test_custom_class_with_equals_is_not_marked() async {
    await assertNoDiagnostics('''
class Value {
  const Value(this.value);

  final int value;

  @override
  bool operator ==(Object other) => other is Value && other.value == value;

  @override
  int get hashCode => value.hashCode;
}

bool test(Value a, Value b) {
  return a == b;
}
''');
  }
}
