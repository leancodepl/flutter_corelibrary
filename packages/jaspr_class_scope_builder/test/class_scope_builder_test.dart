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

String _suffixIn(String generated) =>
    RegExp(r"ClassScope\('\w+', '(\w+)'\)").firstMatch(generated)!.group(1)!;

void main() {
  group('ClassScopeBuilder', () {
    test('writes a scope for an annotated component', () async {
      final written = await _build({'site|lib/components/hero.dart': _hero});

      final output = written.testing.readString(
        AssetId('site', 'lib/components/hero.scopes.dart'),
      );

      expect(output, contains("part of 'hero.dart';"));
      expect(
        output,
        contains(
          r"const _$heroScope = ClassScope('Hero', "
          "'${classScopeSuffix('site|lib/components/hero.dart#Hero')}');",
        ),
      );
    });

    // The whole point of hashing the asset instead of the class name.
    test('gives two components of the same name different suffixes', () async {
      final written = await _build({
        'site|lib/components/hero.dart': _hero,
        'site|lib/marketing/hero.dart': _hero,
      });

      final first = written.testing.readString(
        AssetId('site', 'lib/components/hero.scopes.dart'),
      );
      final second = written.testing.readString(
        AssetId('site', 'lib/marketing/hero.scopes.dart'),
      );

      expect(
        _suffixIn(first),
        isNot(_suffixIn(second)),
        reason: 'two Hero classes must not share one namespace',
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
class CardGrid {}

class NotAComponent {}
''',
      });

      final output = written.testing.readString(
        AssetId('site', 'lib/cards.scopes.dart'),
      );

      expect(output, contains(r"const _$cardScope = ClassScope('Card'"));
      expect(
        output,
        contains(r"const _$cardGridScope = ClassScope('CardGrid'"),
      );
      expect(output, isNot(contains('NotAComponent')));
    });
  });
}
