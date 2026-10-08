import 'package:analyzer_testing/analysis_rule/analysis_rule.dart';
import 'package:leancode_lint/config.dart';
import 'package:leancode_lint/src/lints/cognitive_complexity.dart';
import 'package:test_reflective_loader/test_reflective_loader.dart';

void main() {
  defineReflectiveSuite(() {
    defineReflectiveTests(CognitiveComplexityTest);
    defineReflectiveTests(CognitiveComplexityCustomMaximumTest);
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
    final code =
        '''
int f($_parameters) ${_body()}
''';
    await assertDiagnostics(code, [
      lint(code.indexOf('f('), 1, messageContainsAll: ["'f'", ' 16,']),
    ]);
  }

  Future<void> test_methodAndConstructor() async {
    final code =
        '''
class C {
  C.named($_parameters) ${_body().replaceAll('return ', 'limit = ')}

  int m($_parameters) ${_body()}
}
''';
    await assertDiagnostics(code, [
      lint(
        code.indexOf('C.named'),
        'C.named'.length,
        messageContainsAll: ["'C.named'"],
      ),
      lint(code.indexOf('m('), 1, messageContainsAll: ["'m'"]),
    ]);
  }

  // Seven of the body's increments are nesting-sensitive, so one level deeper
  // it scores 23. Only the first level of nested functions adds a level, so
  // `i`, nested in `h`, scores the same.
  Future<void> test_nestedFunctionsAreScoredOnTheirOwn() async {
    final code =
        '''
void f($_parameters) {
  if (a) {}
  int g() ${_body()}
  final h = () {
    final i = () ${_body()};
  };
}
''';
    await assertDiagnostics(code, [
      lint(code.indexOf('g('), 1, messageContainsAll: ["'g'", ' 23,']),
      lint(
        code.indexOf('()', code.indexOf('i =')),
        2,
        messageContainsAll: ['closure', ' 23,'],
      ),
    ]);
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
