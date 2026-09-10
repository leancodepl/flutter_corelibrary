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

    // The first four bytes of the md5, so that `md5sum` says the same thing:
    // '' digests to d41d8cd9…, 'abc' to 90015098…, both taken mod 36^6.
    test('is the md5', () {
      expect(classScopeSuffix(''), 'murffd'); // 0xd41d8cd9
      expect(classScopeSuffix('abc'), '3yfdlk'); // 0x90015098
    });

    // The suffix ends up in the rendered page and in the stylesheet built from
    // it, so it may not move between versions of this package.
    test('hashes to a stable suffix', () {
      expect(classScopeSuffix('Hero'), 'qbywlo');
      expect(classScopeSuffix('NavBar'), 'poogac');
      expect(classScopeSuffix('site|lib/components/hero.dart#Hero'), 'lz7xyh');
      // Hashed as UTF-8 bytes.
      expect(classScopeSuffix('ą'), 'oaa6rb');
    });

    test('gives two files different suffixes', () {
      expect(
        classScopeSuffix('site|lib/components/hero.dart#Hero'),
        isNot(classScopeSuffix('site|lib/marketing/hero.dart#Hero')),
      );
    });
  });
}
