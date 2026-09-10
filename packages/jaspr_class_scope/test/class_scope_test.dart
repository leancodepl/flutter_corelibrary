import 'package:jaspr_class_scope/jaspr_class_scope.dart';
import 'package:test/test.dart';

class Hero {}

class NavBar {}

void main() {
  setUp(ClassScope.resetRegistry);

  group('ClassScope', () {
    test('names itself after the type it was made for', () {
      expect(ClassScope.ofType(Hero).name, 'Hero');
      expect(const ClassScope('Hero').name, 'Hero');
    });

    test('hashes the name to five base-36 digits', () {
      expect(
        const ClassScope('Hero').suffix,
        matches(RegExp(r'^[0-9a-z]{5}$')),
      );
    });

    // The suffix ends up in the rendered page and in every stylesheet built
    // from it, so it may not move between platforms or package versions.
    test('hashes to a stable suffix', () {
      expect(const ClassScope('Hero').suffix, '174ao');
      expect(const ClassScope('NavBar').suffix, 'f1teh');
      expect(const ClassScope('Footer').suffix, 'o8nb2');
      expect(const ClassScope('').suffix, 'ztntf');
      expect(const ClassScope('ą').suffix, '0f41s');
    });

    test('gives the same suffix to a type and the name it spells', () {
      expect(ClassScope.ofType(Hero).suffix, const ClassScope('Hero').suffix);
    });

    test('gives different scopes different suffixes', () {
      expect(
        const ClassScope('Hero').suffix,
        isNot(const ClassScope('NavBar').suffix),
      );
    });

    test('throws when two scopes hash alike', () {
      // The shortest pair of names that collides under this hash.
      expect(const ClassScope('FO').suffix, '100sk');
      expect(
        () => const ClassScope('bje').suffix,
        throwsA(
          isA<StateError>().having(
            (e) => e.message,
            'message',
            allOf(contains('FO'), contains('bje'), contains('-100sk')),
          ),
        ),
      );
    });

    test('lets the same scope render again', () {
      expect(
        () => [const ClassScope('Hero').suffix, ClassScope.ofType(Hero).suffix],
        returnsNormally,
      );
    });
  });

  group('ClassName', () {
    const scope = ClassScope('Hero');

    test('renders a scoped class as local-suffix', () {
      expect(scope('grid').name, 'grid-174ao');
      expect(scope('grid').selector, '.grid-174ao');
    });

    test('renders a shared class as written', () {
      expect(const ClassName.shared('af-container').name, 'af-container');
      expect(const ClassName.shared('af-container').selector, '.af-container');
    });

    test('scopes the same local name differently per component', () {
      expect(
        scope('grid').name,
        isNot(const ClassScope('NavBar')('grid').name),
      );
    });

    test('combines two classes onto one element', () {
      final combined = scope('button') + const ClassName.shared('af-primary');

      expect(combined.name, 'button-174ao af-primary');
      expect(combined.selector, '.button-174ao.af-primary');
    });

    test('combines more than two classes, left to right', () {
      final combined =
          const ClassName.shared('a') +
          const ClassName.shared('b') +
          const ClassName.shared('c');

      expect(combined.name, 'a b c');
      expect(combined.selector, '.a.b.c');
    });

    test('is a value: equal when it renders the same', () {
      expect(scope('grid'), ClassScope.ofType(Hero)('grid'));
      expect(scope('grid').hashCode, ClassScope.ofType(Hero)('grid').hashCode);
      expect(scope('grid'), isNot(scope('list')));
      expect(scope('grid'), isNot(const ClassName.shared('grid')));
    });

    test('stringifies to the name it renders', () {
      expect('${scope('grid')}', 'grid-174ao');
      expect(
        'class="${const ClassName.shared('af-container')}"',
        'class="af-container"',
      );
    });
  });
}
