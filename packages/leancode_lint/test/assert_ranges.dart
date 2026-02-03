import 'package:analyzer/src/test_utilities/test_code_format.dart';
import 'package:analyzer_testing/analysis_rule/analysis_rule.dart';

extension AssertDiagnosticsInRangesX on AnalysisRuleTest {
  // TODO: replace with a first-party solution
  // See https://github.com/dart-lang/sdk/issues/61889
  Future<void> assertDiagnosticsInRanges(
    String content, {
    bool positionShorthand = true,
    bool rangeShorthand = true,
    bool zeroWidthMarker = true,
  }) {
    final code = TestCode.parse(
      content,
      positionShorthand: positionShorthand,
      rangeShorthand: rangeShorthand,
      zeroWidthMarker: zeroWidthMarker,
    );
    return assertDiagnostics(code.code, [
      for (final range in code.ranges)
        lint(range.sourceRange.offset, range.sourceRange.length),
      for (final position in code.positions) lint(position.offset, 0),
    ]);
  }
}
