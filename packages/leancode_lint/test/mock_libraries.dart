import 'package:analyzer_testing/analysis_rule/analysis_rule.dart';

part 'mock_libraries/bloc.dart';
part 'mock_libraries/flutter.dart';
part 'mock_libraries/flutter_bloc.dart';
part 'mock_libraries/flutter_hooks.dart';
part 'mock_libraries/hooks_riverpod.dart';
part 'mock_libraries/sliver_tools.dart';

extension on AnalysisRuleTest {
  void appendFile(String path, String content) {
    final file = getFile(path);
    final oldContent = file.readAsStringSync();
    file.writeAsStringSync('$oldContent\n$content');
  }
}
