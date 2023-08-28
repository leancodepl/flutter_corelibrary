// This is the entrypoint of our custom linter

import 'package:custom_lint_builder/custom_lint_builder.dart';
import 'package:leancode_lint/custom_lints/add_sliver_prefix_for_widget_returning_sliver.dart';
import 'package:leancode_lint/custom_lints/start_comment_with_space.dart';
import 'package:leancode_lint/custom_lints/use_design_system_item.dart';

PluginBase createPlugin() => _Linter();

class _Linter extends PluginBase {
  @override
  List<LintRule> getLintRules(CustomLintConfigs configs) => [
        StartCommentWithSpace(),
        ...?UseDesignSystemItem.getRulesListFromConfigs(configs),
        AddSliverPrefixForWidgetReturningSliver(),
      ];

  @override
  List<Assist> getAssists() => [];
}
