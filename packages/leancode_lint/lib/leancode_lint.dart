import 'package:custom_lint_builder/custom_lint_builder.dart';
import 'package:leancode_lint/assists/convert_record_into_nominal_type.dart';
import 'package:leancode_lint/lints/add_sliver_prefix_for_widget_returning_sliver.dart';
import 'package:leancode_lint/lints/start_comment_with_space.dart';
import 'package:leancode_lint/lints/use_design_system_item.dart';

PluginBase createPlugin() => _Linter();

class _Linter extends PluginBase {
  @override
  List<LintRule> getLintRules(CustomLintConfigs configs) => [
        StartCommentWithSpace(),
        ...UseDesignSystemItem.getRulesListFromConfigs(configs),
        AddSliverPrefixForWidgetReturningSliver(),
      ];

  @override
  List<Assist> getAssists() => [
        ConvertRecordIntoNominalType(),
      ];
}
