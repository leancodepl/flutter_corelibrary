import 'package:enhanced_gradients/src/hct_color_tween.dart';
import 'package:glados/glados.dart';

import '../generators.dart';
import '../lerp_suite.dart';

void main() {
  group('HctColorTween', () {
    Glados3(
      any.color,
      any.color,
      any.interpolationParameter,
    ).test('.lerp yields same results as lerpHct standalone function',
        (begin, end, t) {
      final tween = HctColorTween(begin: begin, end: end);

      expect(tween.lerp(t), lerpHct(begin, end, t));
    });
  });

  group('lerpHct', () {
    testLerp('passes basic lerp tests', lerp: lerpHct, generator: any.color);

    Glados2(any.color, any.interpolationParameter).test(
        "when first color is null it interpolates second color's transparency",
        (colorB, t) {
      final result = lerpHct(null, colorB, t);

      final resultAlpha = result!.alpha;
      final expectedAlpha = colorB.alpha * t;

      expect(resultAlpha, closeTo(expectedAlpha, 1));
    });

    Glados2(any.color, any.interpolationParameter).test(
        "when second color is null it interpolates first color's transparency",
        (colorA, t) {
      final result = lerpHct(colorA, null, t);

      final resultAlpha = result!.alpha;
      final expectedAlpha = colorA.alpha * (1 - t);

      expect(resultAlpha, closeTo(expectedAlpha, 1));
    });

    // I intended to test things like "lerping at t = 0.5 should yield a color
    // with average hue, chroma, tone and opacity" but it turns out that
    // RGB <-> HCT conversion is not invertible and in multiple instances
    // a single RGB color can correspond to multiple HCT colors.
  });
}
