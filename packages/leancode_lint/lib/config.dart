import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/file_system/file_system.dart';
import 'package:analyzer/src/workspace/pub.dart';
import 'package:yaml/yaml.dart';

class LeancodeLintConfig {
  LeancodeLintConfig._(this.configMap);

  static LeancodeLintConfig? fromRuleContext(RuleContext context) {
    final package = context.package;
    if (package is! PubPackage) {
      return null;
    }

    final analysisOptionsFile = package
        .workspace
        .packageConfigFile
        .parent
        .parent
        .getChildAssumingFile('analysis_options.yaml');

    return LeancodeLintConfig.fromAnalysisOptions(analysisOptionsFile);
  }

  static LeancodeLintConfig? fromAnalysisOptions(File analysisOptionsFile) {
    if (!analysisOptionsFile.exists) {
      return null;
    }
    final analysisOptions =
        loadYaml(analysisOptionsFile.readAsStringSync()) as YamlMap;

    final configMap = analysisOptions['leancode_lint'];
    if (configMap is! YamlMap) {
      return null;
    }

    return LeancodeLintConfig._(configMap);
  }

  final YamlMap configMap;

  String? get applicationPrefix => switch (configMap) {
    {'application_prefix': final String prefix} => prefix,
    _ => null,
  };
}
