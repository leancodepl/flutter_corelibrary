import 'package:jaspr_class_scope_builder/src/suffix.dart';
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

    // MurmurHash3's published vectors, so that this stays the hash it claims
    // to be.
    test('is MurmurHash3 x86_32', () {
      expect(classScopeSuffix(''), '000000'); // 0
      expect(classScopeSuffix('a'), 'gos6uq'); // 0x3c2569b2
      expect(classScopeSuffix('abc'), 'dwmk8q'); // 0xb3dd93fa
    });

    // The suffix ends up in the rendered page and in the stylesheet built from
    // it, so it may not move between versions of this package.
    test('hashes to a stable suffix', () {
      expect(classScopeSuffix('Hero'), 'mthhuz');
      expect(classScopeSuffix('NavBar'), 'e97iy4');
      expect(classScopeSuffix('site|lib/components/hero.dart#Hero'), 'iur6ms');
      // Hashed as UTF-8 bytes, the way Murmur is defined.
      expect(classScopeSuffix('ą'), 'a8fliq');
    });

    test('gives two files different suffixes', () {
      expect(
        classScopeSuffix('site|lib/components/hero.dart#Hero'),
        isNot(classScopeSuffix('site|lib/marketing/hero.dart#Hero')),
      );
    });
  });
}
