import 'package:analysis_server_plugin/plugin.dart';
import 'package:analysis_server_plugin/registry.dart';
import 'package:leancode_lint/assists/convert_iterable_map_to_collection_for.dart';
import 'package:leancode_lint/assists/convert_positional_to_named_formal.dart';
import 'package:leancode_lint/assists/convert_record_into_nominal_type.dart';
import 'package:leancode_lint/lints/add_cubit_suffix_for_cubits.dart';
import 'package:leancode_lint/lints/avoid_conditional_hooks.dart';
import 'package:leancode_lint/lints/avoid_single_child_in_multi_child_widget.dart';
import 'package:leancode_lint/lints/catch_parameter_names.dart';
import 'package:leancode_lint/lints/hook_widget_does_not_use_hooks.dart';
import 'package:leancode_lint/lints/prefer_center_over_align.dart';
import 'package:leancode_lint/lints/start_comments_with_space.dart';
import 'package:leancode_lint/lints/use_align.dart';
import 'package:leancode_lint/lints/use_dedicated_media_query_methods.dart';
import 'package:leancode_lint/lints/use_padding.dart';

final plugin = _Linter();

class _Linter extends Plugin {
  // @override
  // List<LintRule> getLintRules(CustomLintConfigs configs) => [
  //   ...UseDesignSystemItem.getRulesListFromConfigs(configs),
  //   PrefixWidgetsReturningSlivers.fromConfigs(configs),
  //   const ConstructorParametersAndFieldsShouldHaveTheSameOrder(),
  // ];

  @override
  void register(PluginRegistry registry) {
    registry
      ..registerAssist(ConvertRecordIntoNominalType.new)
      ..registerAssist(ConvertPositionalToNamedFormal.new)
      ..registerAssist(ConvertIterableMapToCollectionFor.new)
      ..registerWarningRule(StartCommentsWithSpace()..registerFixes(registry))
      ..registerWarningRule(AddCubitSuffixForYourCubits())
      ..registerWarningRule(CatchParameterNames())
      ..registerWarningRule(AvoidConditionalHooks())
      ..registerWarningRule(
        HookWidgetDoesNotUseHooks()..registerFixes(registry),
      )
      ..registerWarningRule(AvoidSingleChildInMultiChildWidgets())
      ..registerWarningRule(UseAlign()..registerFixes(registry))
      ..registerWarningRule(UsePadding())
      ..registerWarningRule(
        UseDedicatedMediaQueryMethods()..registerFixes(registry),
      )
      ..registerWarningRule(PreferCenterOverAlign()..registerFixes(registry));
  }
}
