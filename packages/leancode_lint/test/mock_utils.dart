import 'package:analyzer_testing/analysis_rule/analysis_rule.dart';

extension AnalysisRuleTestMockAppend on AnalysisRuleTest {
  void appendFile(String path, String content) {
    final file = getFile(path);
    final oldContent = file.readAsStringSync();
    file.writeAsStringSync('$oldContent\n$content');
  }
}
