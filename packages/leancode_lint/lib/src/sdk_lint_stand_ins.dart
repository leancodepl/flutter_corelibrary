import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/error/error.dart';
// The registry `linter.rules` is resolved against. It has no public equivalent.
// ignore: implementation_imports
import 'package:analyzer/src/lint/registry.dart';

/// SDK lints that assists shape their output after.
const sdkLintStandIns = [
  'empty_container_bodies',
  'unnecessary_type_name_in_constructor',
  'use_declaring_parameters',
  'use_primary_constructors',
];

/// Lets `AnalysisOptions.isLintEnabled` answer for [sdkLintStandIns] inside
/// the plugin isolate.
///
/// The SDK's lint rules are only registered in the analysis server's isolate,
/// and the options parser drops every `linter.rules` entry without a
/// registered rule. A no-op rule under each SDK lint's name keeps the entry,
/// with the analyzer's own handling of includes and overrides.
void registerSdkLintStandIns() {
  for (final name in sdkLintStandIns) {
    if (Registry.ruleRegistry.getRule(name) == null) {
      Registry.ruleRegistry.registerLintRule(_SdkLintStandIn(name));
    }
  }
}

final class _SdkLintStandIn(final String ruleName) extends AnalysisRule {
  this : super(name: ruleName, description: 'Stands in for the SDK lint.');

  @override
  LintCode get diagnosticCode => .new(ruleName, description);

  @override
  void registerNodeProcessors(
    RuleVisitorRegistry registry,
    RuleContext context,
  ) {}
}
