import 'package:analysis_server_plugin/src/correction/fix_generators.dart';
import 'package:analyzer_testing/analysis_rule/analysis_rule.dart';
import 'package:leancode_lint/config.dart';
import 'package:leancode_lint/src/lints/prefer_dot_shorthand.dart';
import 'package:test_reflective_loader/test_reflective_loader.dart';

import '../assert_fixes.dart';
import '../assert_ranges.dart';

void main() {
  defineReflectiveSuite(() {
    defineReflectiveTests(PreferDotShorthandTest);
    defineReflectiveTests(PreferDotShorthandWithoutUnnamedConstructorsTest);
    defineReflectiveTests(PreferDotShorthandWithoutNamedConstructorsTest);
    defineReflectiveTests(PreferDotShorthandWithoutStaticMembersTest);
    defineReflectiveTests(PreferDotShorthandWithoutEnumValuesTest);
  });
}

const _style = '''
enum Style { plain, bold }
''';

// Declarations with one member of each kind that the rule can report.
const _kinds = '''
enum Style { plain, bold }
class Key {
  const Key(this.a);
  const Key.named(this.a);
  final int a;
  static const zero = Key(0);
}
''';

abstract class _PreferDotShorthandTestBase() extends AnalysisRuleTest {
  PreferDotShorthandConfig get config;

  @override
  void setUp() {
    rule = PreferDotShorthand(config: config);
    super.setUp();
    registeredFixGenerators.registerFixForLint(
      PreferDotShorthand.code,
      ReplaceWithDotShorthand.new,
    );
  }

  @override
  Future<void> tearDown() async {
    registeredFixGenerators.lintProducers.remove(PreferDotShorthand.code);
    await super.tearDown();
  }

  /// Asserts the `prefer_dot_shorthand` diagnostics marked in [content], and
  /// that applying all offered fixes results in [fixed].
  Future<void> assertShorthands(String content, {required String fixed}) =>
      assertFixes(
        content,
        code: PreferDotShorthand.code,
        fixKind: ReplaceWithDotShorthand.kind,
        fixed: fixed,
      );
}

@reflectiveTest
class PreferDotShorthandTest() extends _PreferDotShorthandTestBase {
  @override
  PreferDotShorthandConfig get config => const .new();

  Future<void> test_argument() async {
    await assertShorthands(
      '''
${_style}void use(Style style) {}
void f() => use([!Style.plain!]);
''',
      fixed:
          '''
${_style}void use(Style style) {}
void f() => use(.plain);
''',
    );
  }

  Future<void> test_namedArgument() async {
    await assertShorthands(
      '''
${_style}void use({required Style style}) {}
void f() => use(style: [!Style.plain!]);
''',
      fixed:
          '''
${_style}void use({required Style style}) {}
void f() => use(style: .plain);
''',
    );
  }

  Future<void> test_typedVariable() async {
    await assertShorthands(
      '''
${_style}void f() {
  Style style = /*[0*/Style.plain/*0]*/;
  style = /*[1*/Style.bold/*1]*/;
}
''',
      fixed:
          '''
${_style}void f() {
  Style style = .plain;
  style = .bold;
}
''',
    );
  }

  Future<void> test_returns() async {
    await assertShorthands(
      '''
${_style}Style f() => /*[0*/Style.plain/*0]*/;
Style g() {
  return /*[1*/Style.bold/*1]*/;
}
Style? h() => /*[2*/Style.plain/*2]*/;
Future<Style> i() async => /*[3*/Style.bold/*3]*/;
''',
      fixed:
          '''
${_style}Style f() => .plain;
Style g() {
  return .bold;
}
Style? h() => .plain;
Future<Style> i() async => .bold;
''',
    );
  }

  Future<void> test_equality() async {
    await assertShorthands(
      '''
${_style}bool f(Style style) => style == /*[0*/Style.plain/*0]*/ || style != /*[1*/Style.bold/*1]*/;
''',
      fixed:
          '''
${_style}bool f(Style style) => style == .plain || style != .bold;
''',
    );
  }

  Future<void> test_branches() async {
    await assertShorthands(
      '''
${_style}Style f(bool b, Style? s) => b ? /*[0*/Style.plain/*0]*/ : (s ?? /*[1*/Style.bold/*1]*/);
Style g(bool b) => switch (b) {
  true => /*[2*/Style.plain/*2]*/,
  false => /*[3*/Style.bold/*3]*/,
};
''',
      fixed:
          '''
${_style}Style f(bool b, Style? s) => b ? .plain : (s ?? .bold);
Style g(bool b) => switch (b) {
  true => .plain,
  false => .bold,
};
''',
    );
  }

  Future<void> test_constantPattern() async {
    await assertShorthands(
      '''
${_style}bool f(Style style) => switch (style) {
  /*[0*/Style.plain/*0]*/ => true,
  _ => false,
};
bool g(Style style) {
  if (style case /*[1*/Style.bold/*1]*/) {
    return true;
  }
  return false;
}
''',
      fixed:
          '''
${_style}bool f(Style style) => switch (style) {
  .plain => true,
  _ => false,
};
bool g(Style style) {
  if (style case .bold) {
    return true;
  }
  return false;
}
''',
    );
  }

  Future<void> test_collections() async {
    await assertShorthands(
      '''
${_style}List<Style> f() => [/*[0*/Style.plain/*0]*/, if (true) /*[1*/Style.bold/*1]*/];
Set<Style> g() => <Style>{/*[2*/Style.plain/*2]*/};
Map<Style, int> h() => {/*[3*/Style.bold/*3]*/: 1};
void i(List<Style> styles) => styles.add(/*[4*/Style.plain/*4]*/);
''',
      fixed:
          '''
${_style}List<Style> f() => [.plain, if (true) .bold];
Set<Style> g() => <Style>{.plain};
Map<Style, int> h() => {.bold: 1};
void i(List<Style> styles) => styles.add(.plain);
''',
    );
  }

  Future<void> test_defaultValue() async {
    await assertShorthands(
      '''
${_style}void f({Style style = [!Style.plain!]}) {}
''',
      fixed:
          '''
${_style}void f({Style style = .plain}) {}
''',
    );
  }

  Future<void> test_constructors() async {
    await assertShorthands(
      '''
class Key {
  const Key(this.a);
  const Key.named(this.a);
  final int a;
}
Key f() => /*[0*/Key(1)/*0]*/;
Key g() => /*[1*/Key.named(2)/*1]*/;
Key h() => /*[2*/const Key(3)/*2]*/;
List<int> i() => /*[3*/List.filled(1, 0)/*3]*/;
''',
      fixed: '''
class Key {
  const Key(this.a);
  const Key.named(this.a);
  final int a;
}
Key f() => .new(1);
Key g() => .named(2);
Key h() => const .new(3);
List<int> i() => .filled(1, 0);
''',
    );
  }

  Future<void> test_staticMembers() async {
    await assertShorthands(
      '''
class Parser {
  static final _instance = Parser();
  static Parser of(String source) => _instance;
  static Parser get shared => _instance;
}
int f() => /*[0*/int.parse('1')/*0]*/;
Parser g() => /*[1*/Parser.of('x')/*1]*/;
Parser h() => /*[2*/Parser.shared/*2]*/;
double i() => /*[3*/double.infinity/*3]*/;
''',
      fixed: '''
class Parser {
  static final _instance = Parser();
  static Parser of(String source) => _instance;
  static Parser get shared => _instance;
}
int f() => .parse('1');
Parser g() => .of('x');
Parser h() => .shared;
double i() => .infinity;
''',
    );
  }

  Future<void> test_importPrefix() async {
    await assertShorthands(
      '''
import 'dart:core' as core;

core.Duration f() => /*[0*/core.Duration.zero/*0]*/;
core.Duration g() => /*[1*/core.Duration(days: 1)/*1]*/;
''',
      fixed: '''
import 'dart:core' as core;

core.Duration f() => .zero;
core.Duration g() => .new(days: 1);
''',
    );
  }

  Future<void> test_noContext() async {
    await assertNoDiagnostics('''
${_style}final a = Style.plain;
final b = () => Style.plain;
int c() => Style.plain.index;
String d() => '\${Style.plain}';
final e = [Style.plain];
''');
  }

  Future<void> test_typeArguments() async {
    await assertShorthands(
      '''
List<int> f() => [!List<int>.filled(1, 0)!];
''',
      fixed: '''
List<int> f() => .filled(1, 0);
''',
    );
  }

  Future<void> test_otherContext() async {
    await assertNoDiagnostics('''
${_style}class Colors {
  static const red = 1;
}
Object a() => Style.plain;
int b() => Colors.red;
List<num> c() => List<int>.filled(1, 0);
''');
  }

  Future<void> test_alreadyShorthand() async {
    await assertNoDiagnostics('''
${_style}Style f() => .plain;
''');
  }

  Future<void> test_annotation() async {
    await assertNoDiagnostics('''
class Timeout {
  const Timeout(Duration duration);
}
@Timeout(Duration(minutes: 1))
void f() {}
''');
  }

  Future<void> test_typeParameterPinnedByContext() async {
    await assertShorthands(
      '''
${_style}T same<T>(T value) => value;
class Box<T> {
  Box(T value);
}
Style f() => same(/*[0*/Style.plain/*0]*/);
Box<Style> g() => /*[1*/Box(/*[2*/Style.plain/*2]*/)/*1]*/;
''',
      fixed:
          '''
${_style}T same<T>(T value) => value;
class Box<T> {
  Box(T value);
}
Style f() => same(.plain);
Box<Style> g() => .new(.plain);
''',
    );
  }

  Future<void> test_typeParameterInferredFromArgument() async {
    await assertNoDiagnostics('''
${_style}T same<T>(T value) => value;
class Box<T> {
  Box(T value);
}
final a = same(Style.plain);
Object b() => same(Style.plain);
final c = Box(Style.plain);
''');
  }
}

@reflectiveTest
class PreferDotShorthandWithoutUnnamedConstructorsTest()
    extends _PreferDotShorthandTestBase {
  @override
  PreferDotShorthandConfig get config => const .new(unnamedConstructors: false);

  Future<void> test_reportsTheOtherKinds() async {
    await assertDiagnosticsInRanges('''
${_kinds}Style a() => /*[0*/Style.plain/*0]*/;
Key b() => Key(1);
Key c() => /*[1*/Key.named(2)/*1]*/;
Key d() => /*[2*/Key.zero/*2]*/;
int e() => /*[3*/int.parse('1')/*3]*/;
''');
  }
}

@reflectiveTest
class PreferDotShorthandWithoutNamedConstructorsTest()
    extends _PreferDotShorthandTestBase {
  @override
  PreferDotShorthandConfig get config => const .new(namedConstructors: false);

  Future<void> test_reportsTheOtherKinds() async {
    await assertDiagnosticsInRanges('''
${_kinds}Style a() => /*[0*/Style.plain/*0]*/;
Key b() => /*[1*/Key(1)/*1]*/;
Key c() => Key.named(2);
Key d() => /*[2*/Key.zero/*2]*/;
int e() => /*[3*/int.parse('1')/*3]*/;
''');
  }
}

@reflectiveTest
class PreferDotShorthandWithoutStaticMembersTest()
    extends _PreferDotShorthandTestBase {
  @override
  PreferDotShorthandConfig get config => const .new(staticMembers: false);

  Future<void> test_reportsTheOtherKinds() async {
    await assertDiagnosticsInRanges('''
${_kinds}Style a() => /*[0*/Style.plain/*0]*/;
Key b() => /*[1*/Key(1)/*1]*/;
Key c() => /*[2*/Key.named(2)/*2]*/;
Key d() => Key.zero;
int e() => int.parse('1');
''');
  }
}

@reflectiveTest
class PreferDotShorthandWithoutEnumValuesTest()
    extends _PreferDotShorthandTestBase {
  @override
  PreferDotShorthandConfig get config => const .new(enumValues: false);

  Future<void> test_reportsTheOtherKinds() async {
    await assertDiagnosticsInRanges('''
${_kinds}Style a() => Style.plain;
Key b() => /*[0*/Key(1)/*0]*/;
Key c() => /*[1*/Key.named(2)/*1]*/;
Key d() => /*[2*/Key.zero/*2]*/;
int e() => /*[3*/int.parse('1')/*3]*/;
''');
  }
}
