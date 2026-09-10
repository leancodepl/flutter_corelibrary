import 'package:jaspr_class_scope/jaspr_class_scope.dart';
import 'package:test/test.dart';

// The scopes a component file gets from `jaspr_class_scope_builder`.
const heroScope = ClassScope('Hero', '16rv7');
const navBarScope = ClassScope('NavBar', '1f3xc');

void main() {
  setUp(ClassScope.resetRegistry);

  group('ClassScope', () {
    test('renders a class as local-suffix', () {
      expect(heroScope('grid').name, 'grid-16rv7');
      expect(heroScope('grid').selector, '.grid-16rv7');
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
      expect(heroScope('grid').name, 'grid-16rv7');
      expect(
        () => const ClassScope('OtherHero', '16rv7')('grid').name,
        throwsA(
          isA<StateError>().having(
            (e) => e.message,
            'message',
            allOf(contains('Hero'), contains('OtherHero'), contains('-16rv7')),
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

      expect(combined.name, 'button-16rv7 primary');
      expect(combined.selector, '.button-16rv7.primary');
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
      expect(heroScope('grid'), const ClassScope('Hero', '16rv7')('grid'));
      expect(heroScope('grid'), isNot(heroScope('list')));
      expect(heroScope('grid'), isNot(const ClassName.shared('grid')));
    });

    test('stringifies to the name it renders', () {
      expect('${heroScope('grid')}', 'grid-16rv7');
      expect('${const ClassName.shared('js-copy')}', 'js-copy');
    });
  });
}
