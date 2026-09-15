import 'package:build/build.dart';
import 'package:build_test/build_test.dart';
import 'package:jaspr_class_scope_builder/jaspr_class_scope_builder.dart';
import 'package:test/test.dart';

const _hero = r'''
import 'package:jaspr_class_scope/jaspr_class_scope.dart';

part 'hero.scopes.dart';

@scopedCss
class Hero {
  static const _class = _$HeroScope;
}
''';

// The annotation, as the package under test's consumers import it.
const _package = {
  'jaspr_class_scope|lib/jaspr_class_scope.dart': '''
final class ScopedCss {
  const ScopedCss();
}

const scopedCss = ScopedCss();
''',
};

Future<TestReaderWriter> _build(Map<String, String> sources) async {
  final result = await testBuilder(
    const ClassScopeBuilder(),
    {..._package, ...sources},
    rootPackage: 'site',
    flattenOutput: true,
  );

  expect(result.errors, isEmpty);

  return result.readerWriter;
}

String _scopesIn(TestReaderWriter written, String path) =>
    written.testing.readString(AssetId('site', path));

void main() {
  group('ClassScopeBuilder', () {
    test('writes a scope for an annotated component', () async {
      final written = await _build({'site|lib/components/hero.dart': _hero});

      final output = _scopesIn(written, 'lib/components/hero.scopes.dart');

      expect(output, contains('// dart format off'));
      expect(output, contains("part of 'hero.dart';"));
      expect(
        output,
        contains(r"const _$HeroScope = ClassScope('Hero', 'lz7xyh');"),
      );
    });

    test('gives two components of the same name different suffixes', () async {
      final written = await _build({
        'site|lib/components/hero.dart': _hero,
        'site|lib/marketing/hero.dart': _hero,
      });

      expect(
        _scopesIn(written, 'lib/components/hero.scopes.dart'),
        contains("ClassScope('Hero', 'lz7xyh')"),
      );
      expect(
        _scopesIn(written, 'lib/marketing/hero.scopes.dart'),
        contains("ClassScope('Hero', 'vldqky')"),
      );
    });

    test('writes nothing for a file without annotated components', () async {
      final written = await _build({'site|lib/plain.dart': 'class Plain {}'});

      expect(
        written.testing.assetsWritten,
        isNot(contains(AssetId('site', 'lib/plain.scopes.dart'))),
      );
    });

    test('writes nothing for a file that declares no part', () async {
      final written = await _build({
        'site|lib/foreign.dart': '''
import 'package:jaspr_class_scope/jaspr_class_scope.dart';

@scopedCss
class Foreign {}
''',
      });

      expect(
        written.testing.assetsWritten,
        isNot(contains(AssetId('site', 'lib/foreign.scopes.dart'))),
      );
    });

    test('skips a same-named annotation from another package', () async {
      final written = await _build({
        'elsewhere|lib/elsewhere.dart': '''
final class ScopedCss {
  const ScopedCss();
}

const scopedCss = ScopedCss();
''',
        'site|lib/hero.dart': '''
import 'package:elsewhere/elsewhere.dart';

part 'hero.scopes.dart';

@scopedCss
class Hero {}
''',
      });

      expect(
        written.testing.assetsWritten,
        isNot(contains(AssetId('site', 'lib/hero.scopes.dart'))),
      );
    });

    test('finds the annotation through a re-export', () async {
      final written = await _build({
        'site|lib/styles.dart':
            "export 'package:jaspr_class_scope/jaspr_class_scope.dart';",
        'site|lib/hero.dart': '''
import 'styles.dart';

part 'hero.scopes.dart';

@scopedCss
class Hero {}
''',
      });

      expect(
        _scopesIn(written, 'lib/hero.scopes.dart'),
        contains(r"const _$HeroScope = ClassScope('Hero', "),
      );
    });

    test('writes one scope per annotated component', () async {
      final written = await _build({
        'site|lib/cards.dart': '''
import 'package:jaspr_class_scope/jaspr_class_scope.dart';

part 'cards.scopes.dart';

@scopedCss
class Card {}

@ScopedCss()
final class CardGrid {}

class NotAComponent {}
''',
      });

      final output = _scopesIn(written, 'lib/cards.scopes.dart');

      expect(output, contains(r"const _$CardScope = ClassScope('Card'"));
      expect(
        output,
        contains(r"const _$CardGridScope = ClassScope('CardGrid'"),
      );
      expect(output, isNot(contains('NotAComponent')));
    });
  });
}
