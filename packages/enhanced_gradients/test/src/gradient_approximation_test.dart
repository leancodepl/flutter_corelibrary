import 'dart:ui';

import 'package:collection/collection.dart';
import 'package:enhanced_gradients/src/gradient_approximation.dart';
import 'package:glados/glados.dart';

import '../generators.dart';

void main() {
  group('approximateGradientPart', () {
    Glados3(any.colorstop, any.colorstop, any.positiveIntOrZero)
        .test('returns n+2 colorstops with n being the subdivision count',
            (a, b, subdivisions) {
      if (a.stop! > b.stop!) {
        final temp = a;
        a = b;
        b = temp;
      }

      final result = approximateGradientPart(
        subdivisions: subdivisions,
        a: a,
        b: b,
        lerpColor: Color.lerp,
      );

      expect(result, hasLength(subdivisions + 2));
    });

    Glados3(any.colorstop, any.colorstop, any.positiveIntOrZero)
        .test('first colorstop on the list is the original start point',
            (a, b, subdivisions) {
      if (a.stop! > b.stop!) {
        final temp = a;
        a = b;
        b = temp;
      }

      final result = approximateGradientPart(
        subdivisions: subdivisions,
        a: a,
        b: b,
        lerpColor: Color.lerp,
      );

      expect(result.first, a);
    });

    Glados3(any.colorstop, any.colorstop, any.positiveIntOrZero)
        .test('last colorstop on the list is the original end point',
            (a, b, subdivisions) {
      if (a.stop! > b.stop!) {
        final temp = a;
        a = b;
        b = temp;
      }

      final result = approximateGradientPart(
        subdivisions: subdivisions,
        a: a,
        b: b,
        lerpColor: Color.lerp,
      );

      expect(result.last, b);
    });

    Glados3(any.colorstop, any.colorstop, any.positiveIntOrZero).test(
        'when both colorstops have non-null stops then all stops are non-null',
        (a, b, subdivisions) {
      if (a.stop! > b.stop!) {
        final temp = a;
        a = b;
        b = temp;
      }

      final result = approximateGradientPart(
        subdivisions: subdivisions,
        a: a,
        b: b,
        lerpColor: Color.lerp,
      );

      expect(
        result.map((colorstop) => colorstop.stop),
        everyElement(isNotNull),
      );
    });

    Glados3(any.colorstop, any.colorstop, any.positiveIntOrZero)
        .test('all stops are in [0,1] range, inclusive', (a, b, subdivisions) {
      if (a.stop! > b.stop!) {
        final temp = a;
        a = b;
        b = temp;
      }

      final result = approximateGradientPart(
        subdivisions: subdivisions,
        a: a,
        b: b,
        lerpColor: Color.lerp,
      );

      expect(
        result.map((colorstop) => colorstop.stop),
        everyElement(inInclusiveRange(0, 1)),
      );
    });
  });

  group('approximateGradient', () {
    Glados2(
      any.positiveIntOrZero,
      any
          .listWithLengthInRange(2, null, any.colorstop)
          .map((list) => list.sortedBy<num>((cs) => cs.stop!)),
    ).test(
      'contains all the original colorstops in the same order',
      (subdivisions, colorstops) {
        final result = approximateGradient(
          colorstops: colorstops,
          lerpColor: Color.lerp,
          subdivisions: subdivisions,
        );

        expect(result, containsAllInOrder(colorstops));
      },
    );
  });

  group('approximateGradientLists', () {
    Glados2(
      any.positiveIntOrZero,
      any
          .listWithLengthInRange(2, null, any.colorstop)
          .map((list) => list.sortedBy<num>((cs) => cs.stop!)),
    ).test(
      'yields same results as approximateGradient, just in different shape',
      (subdivisions, colorstops) {
        final colors = colorstops.map((cs) => cs.color).toList();
        final stops = colorstops.map((cs) => cs.stop!).toList();
        final (resultColors, resultStops) = approximateGradientLists(
          colors: colors,
          stops: stops,
          lerp: Color.lerp,
          subdivisions: subdivisions,
        );

        final expectedColorstops = approximateGradient(
          colorstops: colorstops,
          subdivisions: subdivisions,
          lerpColor: Color.lerp,
        );

        expect(resultColors, expectedColorstops.map((cs) => cs.color));
        expect(resultStops, expectedColorstops.map((cs) => cs.stop!));
      },
    );
  });
}
