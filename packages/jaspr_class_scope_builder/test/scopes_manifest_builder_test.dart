import 'dart:convert';

import 'package:build/build.dart';
import 'package:build_test/build_test.dart';
import 'package:jaspr_class_scope_builder/jaspr_class_scope_builder.dart';
import 'package:jaspr_class_scope_builder/src/suffix.dart';
import 'package:test/test.dart';

String _component(String name) => """
import 'package:jaspr_class_scope/jaspr_class_scope.dart';

@scopedCss
class $name {}
""";

Future<List<Object?>?> _manifestOf(Map<String, String> sources) async {
  final result = await testBuilder(
    const ScopesManifestBuilder(),
    {r'site|lib/$lib$': '', ...sources},
    rootPackage: 'site',
    flattenOutput: true,
  );

  expect(result.errors, isEmpty);

  final manifest = AssetId('site', 'lib/jaspr_class_scope.scopes.json');
  if (!result.readerWriter.testing.assetsWritten.contains(manifest)) {
    return null;
  }

  return jsonDecode(result.readerWriter.testing.readString(manifest))
      as List<Object?>;
}

void main() {
  group('ScopesManifestBuilder', () {
    test('lists every annotated component with its suffix', () async {
      final manifest = await _manifestOf({
        'site|lib/hero.dart': _component('Hero'),
        'site|lib/plain.dart': 'class Plain {}',
      });

      expect(manifest, [
        {
          'suffix': classScopeSuffix('site|lib/hero.dart#Hero'),
          'owner': 'Hero (site|lib/hero.dart)',
        },
      ]);
    });

    test('reads the sources, not the generated part files', () async {
      final manifest = await _manifestOf({
        'site|lib/hero.dart': _component('Hero'),
        // Whatever the generator wrote is beside the point; a stale or
        // reformatted part file cannot make the check miss a component.
        'site|lib/hero.scopes.dart': "part of 'hero.dart';",
      });

      expect(manifest, hasLength(1));
    });

    test('writes nothing for a package without annotated components', () async {
      expect(
        await _manifestOf({'site|lib/plain.dart': 'class Plain {}'}),
        isNull,
      );
    });
  });
}
