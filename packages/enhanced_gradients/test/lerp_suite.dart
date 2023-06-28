import 'package:glados/glados.dart';
import 'package:meta/meta.dart';

import 'generators.dart';

/// Runs basic tests for linear interpolation function [lerp]
@isTestGroup
void testLerp<T>(
  String description, {
  required T? Function(T? a, T? b, double t) lerp,
  required Generator<T> generator,
}) {
  group(description, () {
    Glados(any.interpolationParameter).test(
        'When both "a" and "b" are null returns null regardless of "t"', (t) {
      expect(lerp(null, null, t), isNull);
    });

    Glados2(generator, generator)
        .test('When t = 0 and "a" and "b" are non-null, returns "a"', (a, b) {
      expect(lerp(a, b, 0), equals(a));
    });

    Glados2(generator, generator)
        .test('When t = 1 and "a" and "b" are non-null, returns "b"', (a, b) {
      expect(lerp(a, b, 1), equals(b));
    });
  });
}
