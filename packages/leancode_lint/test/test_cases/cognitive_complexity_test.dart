import 'package:analyzer_testing/analysis_rule/analysis_rule.dart';
import 'package:leancode_lint/config.dart';
import 'package:leancode_lint/src/lints/cognitive_complexity.dart';
import 'package:test_reflective_loader/test_reflective_loader.dart';

import '../assert_ranges.dart';

void main() {
  defineReflectiveSuite(() {
    defineReflectiveTests(CognitiveComplexityTest);
    defineReflectiveTests(CognitiveComplexityCustomMaximumTest);
    defineReflectiveTests(CognitiveComplexityFreeConstructsTest);
  });
}

// Scores 16: one over the maximum. The trailing comments give each increment.
String _body() => '''
{
    var total = 0;
    outer:
    for (final row in rows) { // 1
      for (final x in row) { // 2
        if (x < 0) { // 3
          continue outer; // 1
        } else if (a && b && x > 9 || x < -9) { // 1 + 2
          total += limit ?? x;
        } else { // 1
          total -= x;
        }
      }
    }
    final picked = rows.where((row) => row.isEmpty).isEmpty ? rows.length : 1; // 1
    try {
      total ~/= picked;
    } on Exception { // 1
      return switch (limit) { null => 0, _ => total }; // 2
    }
    return a ? total : -total; // 1
  }''';

const _parameters = 'List<List<int>> rows, int? limit, bool a, bool b';

@reflectiveTest
class CognitiveComplexityTest() extends AnalysisRuleTest {
  @override
  void setUp() {
    rule = CognitiveComplexity(config: const .new());
    super.setUp();
  }

  Future<void> test_atMaximum() async {
    await assertNoDiagnostics('''
int f($_parameters) ${_body().replaceFirst('outer:', '').replaceFirst('continue outer;', 'continue;')}
''');
  }

  Future<void> test_overMaximum() async {
    await assertDiagnosticsInRanges(
      '''
int [!f!]($_parameters) ${_body()}
''',
      messageContainsAll: [
        ['function', ' 16,'],
      ],
    );
  }

  Future<void> test_methodAndConstructor() async {
    await assertDiagnosticsInRanges(
      '''
class C {
  /*[0*/C.named/*0]*/($_parameters) ${_body().replaceAll('return ', 'limit = ')}

  int /*[1*/m/*1]*/($_parameters) ${_body()}
}
''',
      messageContainsAll: [
        ['constructor'],
        ['method'],
      ],
    );
  }

  Future<void> test_primaryConstructor() async {
    await assertDiagnosticsInRanges(
      '''
class C($_parameters) {
  [!this!] ${_body().replaceAll('return ', 'final _ = ')}
}
''',
      messageContainsAll: [
        ['constructor', ' 16,'],
      ],
    );
  }

  // Seven of the body's increments are nesting-sensitive, so one level deeper
  // it scores 23. Only the first level of nested functions adds a level, so
  // `i`, nested in `h`, scores the same.
  Future<void> test_nestedFunctionsAreScoredOnTheirOwn() async {
    await assertDiagnosticsInRanges(
      '''
void f($_parameters) {
  if (a) {}
  int /*[0*/g/*0]*/() ${_body()}
  final h = () {
    final i = /*[1*/()/*1]*/ ${_body()};
  };
}
''',
      messageContainsAll: [
        ['function', ' 23,'],
        ['closure', ' 23,'],
      ],
    );
  }
}

@reflectiveTest
class CognitiveComplexityCustomMaximumTest() extends AnalysisRuleTest {
  @override
  void setUp() {
    rule = CognitiveComplexity(
      config: const CognitiveComplexityConfig(maximum: 16),
    );
    super.setUp();
  }

  Future<void> test_atCustomMaximum() async {
    await assertNoDiagnostics('''
int f($_parameters) ${_body()}
''');
  }
}

@reflectiveTest
class CognitiveComplexityFreeConstructsTest() extends AnalysisRuleTest {
  @override
  void setUp() {
    rule = CognitiveComplexity(
      config: const CognitiveComplexityConfig(maximum: 0),
    );
    super.setUp();
  }

  Future<void> test_nullAwareOperatorsAndCollectionIf() async {
    await assertNoDiagnostics('''
class C {
  int? x;
  C? next;
  List<int>? items;
}

List<int> f(C? c, int? limit, int? extra, bool a) {
  c?.next?.x;
  c?..x = 1;
  c?.items?[0];
  final n = limit ?? 0;
  limit ??= n;
  final d = c!;
  return [
    if (a) 1 else 2,
    ?extra,
    ...?d.items,
    if (d case C(:final x?)) x,
  ];
}
''');
  }
}
