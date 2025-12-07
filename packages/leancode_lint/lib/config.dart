// TODO: use a canonical way to access analysis options (https://github.com/dart-lang/sdk/issues/61755)
// ignore_for_file: implementation_imports

import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/src/analysis_options/analysis_options_provider.dart';
import 'package:analyzer/src/workspace/pub.dart';
import 'package:yaml/yaml.dart';

class LeancodeLintConfig {
  LeancodeLintConfig._(this.configMap);

  factory LeancodeLintConfig.fromRuleContext(RuleContext context) {
    final package = context.package;
    if (package is! PubPackage) {
      return _empty;
    }

    final provider = AnalysisOptionsProvider(
      .new([package.workspace.packageUriResolver]),
    );

    final analysisOptionsFile = provider.getOptionsFile(
      context.definingUnit.file.parent,
    );

    if (analysisOptionsFile == null) {
      return _empty;
    }
    final analysisOptions =
        loadYaml(analysisOptionsFile.readAsStringSync()) as YamlMap;

    final configMap = analysisOptions['leancode_lint'];
    if (configMap is! YamlMap) {
      return _empty;
    }

    return ._(configMap);
  }

  static final _empty = LeancodeLintConfig._(.new());

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
