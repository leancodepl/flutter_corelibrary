import 'package:build/build.dart';
import 'package:build_test/build_test.dart';
import 'package:jaspr_class_scope_builder/jaspr_class_scope_builder.dart';
import 'package:test/test.dart';

const _hero = r'''

part 'hero.scopes.dart';

@scopedCss
class Hero {
  static const _class = _$heroScope;
}
''';

Future<TestReaderWriter> _build(Map<String, String> sources) async {
  final result = await testBuilder(
    const ClassScopeBuilder(),
    sources,
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
      // The suffix of `site|lib/components/hero.dart#Hero`, spelled out: it is
      // rendered into a page, so the path it is hashed from is a contract.
      expect(
        output,
        contains(r"const _$heroScope = ClassScope('Hero', 'lz7xyh');"),
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

    test('writes one scope per annotated component', () async {
      final written = await _build({
        'site|lib/cards.dart': '''

part 'cards.scopes.dart';

@scopedCss
class Card {}

@ScopedCss()
final class CardGrid {}

class NotAComponent {}
''',
      });

      final output = _scopesIn(written, 'lib/cards.scopes.dart');

      expect(output, contains(r"const _$cardScope = ClassScope('Card'"));
      expect(
        output,
        contains(r"const _$cardGridScope = ClassScope('CardGrid'"),
      );
      expect(output, isNot(contains('NotAComponent')));
    });
  });
}
