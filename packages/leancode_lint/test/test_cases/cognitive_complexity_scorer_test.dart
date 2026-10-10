import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:leancode_lint/src/lints/cognitive_complexity.dart';
import 'package:test/test.dart';

/// The scores of [code]'s first declaration and the functions nested in it,
/// keyed by the source each is reported at.
Map<String, int> _scores(String code) {
  final unit = parseString(content: code).unit;
  final declaration = switch (unit.declarations.first) {
    ClassDeclaration(body: BlockClassBody(:final members)) => members.first,
    final declaration => declaration,
  };
  return {
    for (final (:range, :complexity, kind: _) in scoreFunctions(declaration))
      code.substring(range.offset, range.end): complexity,
  };
}

void main() {
  group('scores the body of f', () {
    const cases = {
      '': 0,
      'if (a) {}': 1,
      'if (a) {} else {}': 2,
      'if (a) {} else if (b) {} else {}': 3,
      'if (a) { if (b) {} }': 3,
      'if (a) {} else { if (b) {} }': 4,
      'for (final x in xs) { if (a) {} }': 3,
      'while (a) {}': 1,
      'do {} while (a);': 1,
      'try {} catch (_) {} finally {}': 1,
      'try {} on Exception { if (a) {} }': 3,
      'a ? 1 : 2;': 1,
      'a ? (b ? 1 : 2) : 3;': 3,
      'switch (a) { case true: break; case false: break; }': 1,
      'final v = switch (a) { true => switch (b) { _ => 1 }, false => 0 };': 3,
      'a && b && a;': 1,
      'a && b || a;': 2,
      'a && (b || a);': 2,
      'if (a && b) {}': 2,
      'outer: for (final x in xs) { continue outer; }': 2,
      '[for (final x in xs) x];': 1,
      '[if (a) 1 else 2];': 0,
      'if (xs case [final x?]) {}': 1,
      'xs?.first ?? 0; xs!.length; [...?xs, ?x];': 0,
    };
    for (final MapEntry(key: body, value: score) in cases.entries) {
      test(body.isEmpty ? '(empty)' : body, () {
        expect(
          _scores('void f(bool a, bool b, List<int?>? xs, int? x) { $body }'),
          containsPair('f', score),
        );
      });
    }
  });

  test('scores nested functions on their own, one level deeper', () {
    expect(
      _scores('''
void f(bool a) {
  if (a) {}
  void g() {
    if (a) {}
    final h = () {
      if (a) {}
    };
  }
}
'''),
      {'f': 1, 'g': 2, '()': 2},
    );
  });

  test('reports a closure at its parameters', () {
    expect(_scores('void f() { final g = <T>(T x) { if (x == null) {} }; }'), {
      'f': 0,
      '(T x)': 2,
    });
  });

  test('scores a method and a constructor, but not its initializers', () {
    expect(
      _scores('''
class C {
  C.named(bool a) : x = a ? 1 : 0 {
    if (a) {}
  }

  final int x;
}
'''),
      {'C.named': 1},
    );
  });
}
