import 'package:custom_lint_builder/custom_lint_builder.dart';
import 'package:leancode_lint/assists/convert_record_into_nominal_type.dart';
import 'package:leancode_lint/lints/add_cubit_suffix_for_cubits.dart';
import 'package:leancode_lint/lints/add_sliver_prefix_for_widget_returning_sliver.dart';
import 'package:leancode_lint/lints/avoid_conditional_hooks.dart';
import 'package:leancode_lint/lints/catch_binding_name.dart';
import 'package:leancode_lint/lints/class_parameters_and_fields_should_have_the_same_order.dart';
import 'package:leancode_lint/lints/hook_widget_does_not_use_hooks.dart';
import 'package:leancode_lint/lints/start_comment_with_space.dart';
import 'package:leancode_lint/lints/use_design_system_item.dart';

PluginBase createPlugin() => _Linter();

class _Linter extends PluginBase {
  @override
  List<LintRule> getLintRules(CustomLintConfigs configs) => [
        StartCommentWithSpace(),
        ...UseDesignSystemItem.getRulesListFromConfigs(configs),
        AddSliverPrefixForWidgetReturningSliver(),
        AddCubitSuffixForYourCubits(),
        CatchBindingName(),
        AvoidConditionalHooks(),
        HookWidgetDoesNotUseHooks(),
        ClassParametersAndFieldsShouldHaveTheSameOrder(),
      ];

  @override
  List<Assist> getAssists() => [
        ConvertRecordIntoNominalType(),
      ];
}
