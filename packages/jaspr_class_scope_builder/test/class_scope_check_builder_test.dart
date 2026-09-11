import 'package:build/build.dart';
import 'package:build_test/build_test.dart';
import 'package:jaspr_class_scope_builder/jaspr_class_scope_builder.dart';
import 'package:test/test.dart';

String _component(String name) => """
import 'package:jaspr_class_scope/jaspr_class_scope.dart';

@scopedCss
class $name {}
""";

void main() {
  group('ClassScopeCheckBuilder', () {
    test('passes when every component has its own suffix', () async {
      final result = await testBuilder(const ClassScopeCheckBuilder(), {
        r'site|$package$': '',
        'site|lib/hero.dart': _component('Hero'),
        'site|lib/card.dart': _component('Card'),
      }, rootPackage: 'site');

      expect(result.succeeded, isTrue);
      expect(result.errors, isEmpty);
    });

    // The one pair of short paths that collides, found by searching the hash.
    test('fails the build when two components share a suffix', () async {
      final result = await testBuilder(const ClassScopeCheckBuilder(), {
        r'site|$package$': '',
        'site|lib/c22156.dart': _component('C22156'),
        'site|lib/c59137.dart': _component('C59137'),
      }, rootPackage: 'site');

      expect(result.succeeded, isFalse);
      expect(
        result.errors.join('\n'),
        allOf(contains('lib/c22156.dart'), contains('lib/c59137.dart')),
      );
    });

    test('reads the sources, not the generated part files', () async {
      final result = await testBuilder(
        const ClassScopeCheckBuilder(),
        {
          r'site|$package$': '',
          'site|lib/hero.dart': _component('Hero'),
          // Whatever the generator wrote is beside the point; a stale or
          // reformatted part file cannot make the check miss a component.
          'site|lib/hero.scopes.dart': "part of 'hero.dart';",
        },
        rootPackage: 'site',
        flattenOutput: true,
      );

      expect(result.succeeded, isTrue);
      expect(
        result.readerWriter.testing.readString(
          AssetId('site', 'jaspr_class_scope.check'),
        ),
        contains('Hero (lib/hero.dart)'),
      );
    });
  });
}
