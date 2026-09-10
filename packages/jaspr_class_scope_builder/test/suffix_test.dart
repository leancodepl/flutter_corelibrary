import 'package:jaspr_class_scope_builder/jaspr_class_scope_builder.dart';
import 'package:test/test.dart';

void main() {
  group('classScopeSuffix', () {
    test('is five base-36 digits', () {
      expect(classScopeSuffix('site|lib/hero.dart#Hero'), hasLength(5));
      expect(
        classScopeSuffix('site|lib/hero.dart#Hero'),
        matches(RegExp(r'^[0-9a-z]{5}$')),
      );
    });

    // The suffix ends up in the rendered page and in the stylesheet built from
    // it, so it may not move between versions of this package.
    test('hashes to a stable suffix', () {
      expect(classScopeSuffix('Hero'), '174ao');
      expect(classScopeSuffix('NavBar'), 'f1teh');
      expect(classScopeSuffix(''), 'ztntf');
      expect(classScopeSuffix('ą'), '0f41s');
      expect(classScopeSuffix('site|lib/components/hero.dart#Hero'), '16rv7');
    });

    test('gives two files different suffixes', () {
      expect(
        classScopeSuffix('site|lib/components/hero.dart#Hero'),
        isNot(classScopeSuffix('site|lib/marketing/hero.dart#Hero')),
      );
    });
  });
}
