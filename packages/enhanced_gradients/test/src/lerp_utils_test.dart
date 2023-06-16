import 'package:enhanced_gradients/src/lerp_utils.dart';
import 'package:glados/glados.dart';

void main() {
  group('lerpDegrees', () {
    Glados(any.t).test('when both parameters are null returns null', (t) {
      expect(lerpDegrees(null, null, t), isNull);
    });

    Glados2(any.t, any.double).test('when first parameter is null returns null',
        (t, b) {
      expect(lerpDegrees(null, b, t), isNull);
    });

    Glados2(any.t, any.double)
        .test('when second parameter is null returns null', (t, a) {
      expect(lerpDegrees(a, null, t), isNull);
    });

    Glados3(any.firstQuadrant, any.fourthQuadrant, any.t).test(
        'interpolating between values in first and fourth quadrant goes through 360°/0°',
        (a, b, t) {
      expect(
        lerpDegrees(a, b, t),
        anyOf(
          inClosedOpenRange(a, 360),
          inInclusiveRange(0, b),
        ),
      );
    });

    Glados(
      any.combine5(
        any.double,
        any.shift,
        any.double,
        any.shift,
        any.t,
        (a, aShift, b, bShift, t) => (a, aShift, b, bShift, t),
      ),
    ).test('yields same results for angle parameters shifted by 360 degrees',
        (params) {
      final (a, aShift, b, bShift, t) = params;

      final original = lerpDegrees(a, b, t);
      final shifted = lerpDegrees(a + aShift, b + bShift, t);
      expect(shifted, closeTo(original!, 1e-5));
    });
  });
}

extension on Any {
  Generator<double> get t => doubleInRange(0, 1 + double.minPositive);

  Generator<double> get firstQuadrant => doubleInRange(0, 90);
  Generator<double> get fourthQuadrant => doubleInRange(270, 360);
  Generator<double> get degree => doubleInRange(0, 360);
  Generator<double> get shift => any.int.map((multiplier) => multiplier * 360);
}
