import 'package:analyzer/analysis_rule/rule_context.dart';
// TODO: use a canonical way to access analysis options (https://github.com/dart-lang/sdk/issues/61755)
// ignore: implementation_imports
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

    if (!analysisOptionsFile.exists) {
      return null;
    }
    final analysisOptions =
        loadYaml(analysisOptionsFile.readAsStringSync()) as YamlMap;

    final configMap = analysisOptions['leancode_lint'];
    if (configMap is! YamlMap) {
      return null;
    }

    return ._(configMap);
  }

  final YamlMap configMap;

  late final applicationPrefix = switch (configMap) {
    {'application_prefix': final String prefix} => prefix,
    _ => null,
  };

  late final designSystemItemReplacements = {
    if (configMap['use_design_system_item'] case final YamlMap map)
      for (final entry in map.entries)
        entry.key as String: [
          for (final (forbidden as YamlMap) in entry.value as List)
            (
              name: forbidden['instead_of'] as String,
              packageName: forbidden['from_package'] as String,
            ),
        ],
  };
}
