import 'package:build/build.dart';
import 'package:build_test/build_test.dart';
import 'package:jaspr_class_scope_builder/jaspr_class_scope_builder.dart';
import 'package:test/test.dart';

String _component(String name) => """
import 'package:jaspr_class_scope/jaspr_class_scope.dart';

@scopedCss
class $name {}
""";

/// The manifests and the check, as `build.yaml` orders them.
Future<TestBuilderResult> _check(Map<String, String> sources) => testBuilders(
  [const ScopesManifestBuilder(), const ClassScopeCheckBuilder()],
  {
    r'site|$package$': '',
    r'site|lib/$lib$': '',
    r'other|lib/$lib$': '',
    ...sources,
  },
  rootPackage: 'site',
  flattenOutput: true,
);

void main() {
  group('ClassScopeCheckBuilder', () {
    test('passes when every component has its own suffix', () async {
      final result = await _check({
        'site|lib/hero.dart': _component('Hero'),
        'site|lib/card.dart': _component('Card'),
        'other|lib/hero.dart': _component('Hero'),
      });

      expect(result.succeeded, isTrue);
      expect(result.errors, isEmpty);
      expect(
        result.readerWriter.testing.readString(
          AssetId('site', 'jaspr_class_scope.check'),
        ),
        allOf(
          contains('Hero (site|lib/hero.dart)'),
          contains('Hero (other|lib/hero.dart)'),
        ),
      );
    });

    // The one pair of short paths that collides, found by searching the hash.
    test('fails the build when two components share a suffix', () async {
      final result = await _check({
        'site|lib/c22156.dart': _component('C22156'),
        'site|lib/c59137.dart': _component('C59137'),
      });

      expect(result.succeeded, isFalse);
      expect(
        result.errors.join('\n'),
        allOf(contains('lib/c22156.dart'), contains('lib/c59137.dart')),
      );
    });

    test('sees a component of another package', () async {
      final result = await _check({
        'site|lib/c37213.dart': _component('C37213'),
        'other|lib/c26278.dart': _component('C26278'),
      });

      expect(result.succeeded, isFalse);
      expect(
        result.errors.join('\n'),
        allOf(
          contains('C37213 (site|lib/c37213.dart)'),
          contains('C26278 (other|lib/c26278.dart)'),
        ),
      );
    });
  });
}
