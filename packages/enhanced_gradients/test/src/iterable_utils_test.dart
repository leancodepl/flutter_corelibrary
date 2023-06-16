import 'dart:math';

import 'package:enhanced_gradients/src/iterable_utils.dart';
import 'package:glados/glados.dart';

void main() {
  group('zip2', () {
    Glados(
      any.positiveIntOrZero.bind(
        (length) => any.combine2(
          any.listWithLength(length, any.double),
          any.listWithLength(length, any.double),
          (listA, listB) => (listA, listB, length),
        ),
      ),
    ).test('any two lists with same length produce iterable with this length',
        (input) {
      final (listA, listB, length) = input;

      assert(listA.length == length);
      assert(listB.length == length);

      final zipped = zip2(listA, listB);

      expect(zipped, hasLength(length));
    });

    Glados2(
      any.list(any.double),
      any.list(any.double),
    ).test('produces iterable with length of the shorter input',
        (listA, listB) {
      final zipped = zip2(listA, listB);
      final shorterLength = min(listA.length, listB.length);

      expect(zipped, hasLength(shorterLength));
    });

    test('zipping empty iterables produces empty iterable', () {
      final zipped = zip2(
        const Iterable<Object?>.empty(),
        const Iterable<Object?>.empty(),
      );

      expect(zipped, isEmpty);
    });
  });

  group('IterableExtension', () {
    group('pairwise', () {
      test('called on empty iterable produces empty iterable', () {
        expect(const Iterable<Object?>.empty().pairwise(), isEmpty);
      });

      test('called on iterable with single element produces empty iterable',
          () {
        expect([1234].pairwise(), isEmpty);
      });

      test('should produce consecutive pairs', () {
        const list = [1, 2, 3, 4, 5];
        expect(
          list.pairwise(),
          [
            (1, 2),
            (2, 3),
            (3, 4),
            (4, 5),
          ],
        );
      });

      Glados(any.listWithLengthInRange(2, null, any.distinctObject)).test(
          'every item except first and last should appear in the output twice, first and last once',
          (list) {
        // Assert that all objects in the list are distinct. Otherwise counting them won't work with our approach
        assert(list.length == list.toSet().length);

        final first = list.first;
        final last = list.last;

        final counter = _SimpleCounter();

        for (final (a, b) in list.pairwise()) {
          counter
            ..increment(a)
            ..increment(b);
        }

        for (final item in list) {
          var expectedCount = 2;
          if (item == first || item == last) {
            expectedCount = 1;
          }
          expect(counter.countFor(item), equals(expectedCount));
        }
      });

      Glados(any.list(any.distinctObject)).test(
          'in each pair first item should be the same as second item in previous pair',
          (list) {
        // Assert that all objects in the list are distinct. Otherwise counting them won't work with our approach
        assert(list.length == list.toSet().length);

        Object? previousB;

        for (final (a, b) in list.pairwise()) {
          if (previousB != null) {
            expect(a, same(previousB));
          }
          previousB = b;
        }
      });
    });
  });
}

extension on Any {
  Generator<Object> get distinctObject =>
      always(Object.new).map((create) => create());
}

class _SimpleCounter {
  final _counter = <Object, int>{};

  void increment(Object key) {
    _counter.update(key, (value) => value + 1, ifAbsent: () => 1);
  }

  int countFor(Object key) => _counter[key] ?? 0;
}
