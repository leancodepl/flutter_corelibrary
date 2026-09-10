import 'package:jaspr_class_scope/jaspr_class_scope.dart';
import 'package:test/test.dart';

// The scopes a component file gets from `jaspr_class_scope_builder`.
const heroScope = ClassScope('Hero', 'iur6ms');
const navBarScope = ClassScope('NavBar', 'q8ks2q');

void main() {
  setUp(ClassScope.resetRegistry);

  group('ClassScope', () {
    test('renders a class as local-suffix', () {
      expect(heroScope('grid').name, 'grid-iur6ms');
      expect(heroScope('grid').selector, '.grid-iur6ms');
    });

    test('scopes the same local name differently per component', () {
      expect(heroScope('grid').name, isNot(navBarScope('grid').name));
    });

    test('lets the same scope render again', () {
      expect(
        () => [heroScope('grid').name, heroScope('list').name],
        returnsNormally,
      );
    });

    // Within a package the builder catches this; two packages can still meet.
    test('throws when two components take one suffix', () {
      expect(heroScope('grid').name, 'grid-iur6ms');
      expect(
        () => const ClassScope('OtherHero', 'iur6ms')('grid').name,
        throwsA(
          isA<StateError>().having(
            (e) => e.message,
            'message',
            allOf(contains('Hero'), contains('OtherHero'), contains('-iur6ms')),
          ),
        ),
      );
    });
  });

  group('ClassName', () {
    test('renders a shared class as written', () {
      expect(const ClassName.shared('af-container').name, 'af-container');
      expect(const ClassName.shared('af-container').selector, '.af-container');
    });

    test('combines classes onto one element', () {
      final combined = heroScope('button') + const ClassName.shared('primary');

      expect(combined.name, 'button-iur6ms primary');
      expect(combined.selector, '.button-iur6ms.primary');
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
      expect(heroScope('grid'), const ClassScope('Hero', 'iur6ms')('grid'));
      expect(heroScope('grid'), isNot(heroScope('list')));
      expect(heroScope('grid'), isNot(const ClassName.shared('grid')));
    });

    test('stringifies to the name it renders', () {
      expect('${heroScope('grid')}', 'grid-iur6ms');
      expect('${const ClassName.shared('js-copy')}', 'js-copy');
    });
  });
}
