import 'package:jaspr_class_scope/jaspr_class_scope.dart';
import 'package:test/test.dart';

// The scopes a component file gets from `jaspr_class_scope_builder`.
const heroScope = ClassScope('Hero', 'lz7xyh');

void main() {
  group('ClassScope', () {
    test('renders a class as local-suffix', () {
      expect(heroScope('grid').name, 'grid-lz7xyh');
      expect(heroScope('grid').selector, '.grid-lz7xyh');
    });
  });

  group('ClassName', () {
    test('renders a shared class as written', () {
      expect(const ClassName.shared('af-container').name, 'af-container');
      expect(const ClassName.shared('af-container').selector, '.af-container');
    });

    test('combines classes onto one element', () {
      final combined = heroScope('button') + const ClassName.shared('primary');

      expect(combined.name, 'button-lz7xyh primary');
      expect(combined.selector, '.button-lz7xyh.primary');
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
      expect(heroScope('grid'), const ClassScope('Hero', 'lz7xyh')('grid'));
      expect(heroScope('grid'), isNot(heroScope('list')));
      expect(heroScope('grid'), isNot(const ClassName.shared('grid')));
    });

    test('stringifies to the name it renders', () {
      expect('${heroScope('grid')}', 'grid-lz7xyh');
      expect('${const ClassName.shared('js-copy')}', 'js-copy');
    });
  });
}
