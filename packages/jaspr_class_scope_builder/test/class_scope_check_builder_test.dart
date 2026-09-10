import 'package:build_test/build_test.dart';
import 'package:jaspr_class_scope_builder/jaspr_class_scope_builder.dart';
import 'package:test/test.dart';

String _scopes(String file, String component, String suffix) => """
part of '$file';

const _\$scope = ClassScope.literal('$component', '$suffix');
""";

void main() {
  group('ClassScopeCheckBuilder', () {
    test('passes when every scope has its own suffix', () async {
      final result = await testBuilder(const ClassScopeCheckBuilder(), {
        r'site|$package$': '',
        'site|lib/hero.scopes.dart': _scopes('hero.dart', 'Hero', '16rv7'),
        'site|lib/card.scopes.dart': _scopes('card.dart', 'Card', '1f3xc'),
      }, rootPackage: 'site');

      expect(result.succeeded, isTrue);
      expect(result.errors, isEmpty);
    });

    test('fails the build when two components share a suffix', () async {
      final result = await testBuilder(const ClassScopeCheckBuilder(), {
        r'site|$package$': '',
        'site|lib/hero.scopes.dart': _scopes('hero.dart', 'Hero', '16rv7'),
        'site|lib/marketing/hero.scopes.dart': _scopes(
          'hero.dart',
          'Hero',
          '16rv7',
        ),
      }, rootPackage: 'site');

      expect(result.succeeded, isFalse);
      expect(
        result.errors.join('\n'),
        allOf(
          contains('lib/hero.scopes.dart'),
          contains('lib/marketing/hero.scopes.dart'),
          contains('-16rv7'),
        ),
      );
    });
  });
}
