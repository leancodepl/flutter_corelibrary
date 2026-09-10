import 'package:jaspr_class_scope_builder/jaspr_class_scope_builder.dart';
import 'package:test/test.dart';

void main() {
  group('classScopeSuffix', () {
    test('is six base-36 digits', () {
      expect(classScopeSuffix('site|lib/hero.dart#Hero'), hasLength(6));
      expect(
        classScopeSuffix('site|lib/hero.dart#Hero'),
        matches(RegExp(r'^[0-9a-z]{6}$')),
      );
    });

    // The suffix ends up in the rendered page and in the stylesheet built from
    // it, so it may not move between versions of this package.
    test('hashes to a stable suffix', () {
      expect(classScopeSuffix('Hero'), 'wszcpk');
      expect(classScopeSuffix('NavBar'), 'jmfbzy');
      expect(classScopeSuffix(''), 'biic5n');
      expect(classScopeSuffix('ą'), 'papbch');
      expect(classScopeSuffix('site|lib/components/hero.dart#Hero'), '0dc8kc');
    });

    test('gives two files different suffixes', () {
      expect(
        classScopeSuffix('site|lib/components/hero.dart#Hero'),
        isNot(classScopeSuffix('site|lib/marketing/hero.dart#Hero')),
      );
    });
  });
}
