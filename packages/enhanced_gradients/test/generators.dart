import 'dart:ui';

import 'package:collection/collection.dart';
import 'package:enhanced_gradients/src/gradient_approximation.dart';
import 'package:glados/glados.dart';

extension Generators on Any {
  Generator<Color> get color => combine4(
        any.uint8,
        any.uint8,
        any.uint8,
        any.uint8,
        Color.fromARGB,
      );

  Generator<double> get interpolationParameter =>
      any.doubleInRange(0, 1 + double.minPositive);

  Generator<Colorstop> get colorstop => combine2(
        color,
        any.interpolationParameter,
        (color, stop) => (color: color, stop: stop),
      );

  Generator<List<Colorstop>> get colorstopList =>
      listWithLengthInRange(2, null, colorstop)
          .map((list) => list.sortedBy<num>((cs) => cs.stop!));
}
