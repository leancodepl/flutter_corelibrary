import 'package:analysis_server_plugin/edit/fix/dart_fix_context.dart';
import 'package:analysis_server_plugin/src/correction/dart_change_workspace.dart';
import 'package:analysis_server_plugin/src/correction/fix_processor.dart';
import 'package:analyzer/dart/analysis/results.dart';
import 'package:analyzer/error/error.dart';
import 'package:analyzer_plugin/protocol/protocol_common.dart';
import 'package:analyzer_plugin/utilities/fixes/fixes.dart';
import 'package:analyzer_testing/analysis_rule/analysis_rule.dart';
import 'package:analyzer_testing/src/test_instrumentation_service.dart';
import 'package:test/test.dart';

import 'assert_ranges.dart';

extension AssertFixesX on AnalysisRuleTest {
  // TODO: replace with a first-party solution
  // See https://github.com/dart-lang/sdk/issues/61889
  /// Asserts the diagnostics marked in [content], as [assertDiagnosticsInRanges]
  /// does, and that applying the fix of kind [fixKind] offered for each of
  /// them (registered under [code]) turns the file into [fixed].
  Future<void> assertFixes(
    String content, {
    required DiagnosticCode code,
    required FixKind fixKind,
    required String fixed,
  }) async {
    await assertDiagnosticsInRanges(content);
    final library = await result.session.getResolvedLibrary(
      testFile.path,
    ) as ResolvedLibraryResult;
    final edits = <SourceEdit>[];
    for (final diagnostic in result.diagnostics) {
      if (diagnostic.diagnosticCode != code) {
        continue;
      }
      final fixes = await computeFixes(
        DartFixContext(
          instrumentationService: TestInstrumentationService(),
          workspace: DartChangeWorkspace([await session]),
          libraryResult: library,
          unitResult: result,
          error: diagnostic,
        ),
      );
      final fix = fixes.singleWhere((fix) => fix.kind == fixKind);
      edits.addAll(fix.change.getFileEdit(testFile.path)!.edits);
    }
    // Later edits first, so earlier offsets stay valid as the text changes.
    edits.sort((a, b) => b.offset.compareTo(a.offset));
    expect(SourceEdit.applySequence(result.content, edits), fixed);
  }
}
