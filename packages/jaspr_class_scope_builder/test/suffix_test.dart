import 'package:jaspr_class_scope_builder/jaspr_class_scope_builder.dart';
import 'package:test/test.dart';

/// MurmurHash3 x86_32 with seed 0, taken modulo 36^6 and padded.
String suffixOf(int hash) =>
    (hash % 279936000000 % 2176782336).toRadixString(36).padLeft(6, '0');

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
    // to be: '' hashes to 0, 'a' to 0x3C2569B2, 'abc' to 0xB3DD93FA.
    test('is MurmurHash3 x86_32', () {
      expect(classScopeSuffix(''), '000000');
      expect(
        classScopeSuffix('a'),
        (0x3c2569b2 % 2176782336).toRadixString(36),
      );
      expect(
        classScopeSuffix('abc'),
        (0xb3dd93fa % 2176782336).toRadixString(36),
      );
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
