import 'dart:ui';

import 'package:collection/collection.dart';
import 'package:enhanced_gradients/src/iterable_utils.dart';

/// Generic linear interpolation function for type T.
typedef LerpFunction<T> = T? Function(T? a, T? b, double t);

/// Colorstop of a gradient.
typedef Colorstop = ({Color color, num? stop});

/// Approximates one part of a gradient defined by two colorstops in a custom
/// color space using a custom color interpolation function `lerpColor`.
/// `subdivisions` parameter describes how precise the approximation should be.
/// The higher the number, the more precise.
///
/// `lerpColor` should never return null when either input color is non-null.
Iterable<Colorstop> approximateGradientPart({
  required int subdivisions,
  required Colorstop a,
  required Colorstop b,
  required LerpFunction<Color> lerpColor,
}) sync* {
  assert(subdivisions >= 0);
  assert(
    () {
      final stopA = a.stop;
      final stopB = b.stop;
      if (stopA == null || stopB == null) {
        return true;
      }
      return stopA <= stopB;
    }(),
    'A gradient must have colorstops in ascending order',
  );
  // We'll use n+2 nodes in total; but iteration starts from 0.
  // 1 original start node [a], 1 original end node [b] and n interpolated
  // nodes in between.
  subdivisions += 1;

  for (var i = 0; i <= subdivisions; i++) {
    final t = (i / subdivisions).clamp(0, 1).toDouble();

    yield (
      color: lerpColor(a.color, b.color, t)!,
      stop: lerpDouble(a.stop, b.stop, t),
    );
  }
}

/// Approximates an entire gradient with possibly more than two colorstops
/// using a custom color interpolation function.
Iterable<Colorstop> approximateGradient({
  required Iterable<Colorstop> colorstops,
  required LerpFunction<Color> lerpColor,
  required int subdivisions,
}) {
  assert(subdivisions >= 0);

  return colorstops.pairwise().expandIndexed((index, pair) {
    final (a, b) = pair;
    return approximateGradientPart(
      subdivisions: subdivisions,
      a: a,
      b: b,
      lerpColor: lerpColor,
    ).skip(
      // Every sub-gradient will overlap its neighbors with start and end color
      // except the first start color and last end color, so let's remove
      // all start colors except the first.
      index == 0 ? 0 : 1,
    );
  });
}

/// Approximates an entire gradient with possibly more than two colorstops
/// using a custom color interpolation function. It acts in the same way
/// as [approximateGradient] but its colorstop API is closer to flutter's.
(List<Color> colors, List<double>? stops) approximateGradientLists({
  required List<Color> colors,
  required List<num>? stops,
  required LerpFunction<Color> lerp,
  required int subdivisions,
}) {
  if (colors.length < 2) {
    throw ArgumentError('A gradient requires at least two colors');
  }
  if (stops != null && stops.length != colors.length) {
    throw ArgumentError('There have to be exactly as many stops as colors');
  }

  final colorstops = zip2(
    colors,
    stops ?? Iterable<num?>.generate(colors.length, (_) => null),
  ).map(
    (colorstop) => (color: colorstop.$1, stop: colorstop.$2),
  );
  final approximated = approximateGradient(
    colorstops: colorstops,
    lerpColor: lerp,
    subdivisions: subdivisions,
  ).toList();

  assert(
    stops == null || approximated.every((e) => e.stop != null),
    'All approximated stops should be defined if original stops '
    'were supplied to function',
  );

  return (
    approximated.map((e) => e.color).toList(),
    stops == null ? null : approximated.map((e) => e.stop!.toDouble()).toList(),
  );
}
