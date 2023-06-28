import 'dart:ui';

/// Interpolates numbers as (angle) degrees, i.e. values in range [0-360).
/// Values outside of this range are taken modulo 360, i.e. value of
/// 365° is same as 5°, -30° is same as 330°.
///
/// This interpolation goes along the shortest path in this space, so e.g.
/// distance from 355° to 5° is 10°.
double? lerpDegrees(num? a, num? b, double t) {
  if (a == null || b == null) {
    return null;
  }

  // ignore: parameter_assignments
  a %= 360;
  // ignore: parameter_assignments
  b %= 360;

  final diff = (a - b).abs();
  if (diff <= 180) {
    return lerpDouble(a, b, t);
  } else if (a > b) {
    return lerpDouble(a, b + 360, t)?.remainder(360);
  } else {
    return lerpDouble(a + 360, b, t)?.remainder(360);
  }
}
