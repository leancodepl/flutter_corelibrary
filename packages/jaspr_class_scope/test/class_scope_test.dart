import 'package:jaspr_class_scope/jaspr_class_scope.dart';
import 'package:test/test.dart';

// The scope a component gets from `jaspr_class_scope_builder`.
const heroScope = ClassScope('Hero', 'lz7xyh');

void main() {
  group('ClassScope', () {
    test('renders a class as local-suffix', () {
      expect(heroScope('grid').name, 'grid-lz7xyh');
      expect(heroScope('grid').selector, '.grid-lz7xyh');
    });

    test('renders its root as the component name in kebab case', () {
      expect(heroScope.root.name, 'hero-lz7xyh');
      expect(heroScope.root.selector, '.hero-lz7xyh');
      expect(
        const ClassScope('SiteFooter', 'lz7xyh').root.name,
        'site-footer-lz7xyh',
      );
      expect(
        const ClassScope('HTMLView', 'lz7xyh').root.name,
        'html-view-lz7xyh',
      );
      expect(
        const ClassScope('Step2Form', 'lz7xyh').root.name,
        'step2-form-lz7xyh',
      );
    });

    test('keeps its root a valid class name whatever the suffix', () {
      // `-1gtfn5` alone would not be: a class cannot start with `-` and a
      // digit.
      expect(
        const ClassScope('SiteFooter', '1gtfn5').root.name,
        'site-footer-1gtfn5',
      );
      expect(
        const ClassScope('_Private', '1gtfn5').root.name,
        '_private-1gtfn5',
      );
      expect(
        const ClassScope(r'$Generated', '1gtfn5').root.name,
        '_generated-1gtfn5',
      );
    });

    test('gives the root the same scope as its other classes', () {
      expect(heroScope.root, heroScope('hero'));
      expect(heroScope.root, isNot(const ClassScope('Hero', 'abc123').root));
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

    test('adds nothing for a null class', () {
      const ClassName? none = null;

      expect(heroScope('button') + none, heroScope('button'));
      expect((heroScope('button') + none).selector, '.button-lz7xyh');
      expect(
        (heroScope('button') + none + const ClassName.shared('primary')).name,
        'button-lz7xyh primary',
      );
      expect(
        (heroScope('button') + const ClassName.shared('primary') + none).name,
        'button-lz7xyh primary',
      );
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
      // And hashes alike, or a set would hold it twice.
      expect({
        heroScope('grid'),
        const ClassScope('Hero', 'lz7xyh')('grid'),
      }, hasLength(1));
    });

    test('stringifies to the name it renders', () {
      expect('${heroScope('grid')}', 'grid-lz7xyh');
      expect('${const ClassName.shared('js-copy')}', 'js-copy');
    });
  });
}
