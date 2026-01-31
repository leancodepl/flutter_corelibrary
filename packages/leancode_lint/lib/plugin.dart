import 'package:analysis_server_plugin/plugin.dart';
import 'package:analysis_server_plugin/registry.dart';
import 'package:leancode_lint/assists/convert_iterable_map_to_collection_for.dart';
import 'package:leancode_lint/assists/convert_positional_to_named_formal.dart';
import 'package:leancode_lint/assists/convert_record_into_nominal_type.dart';
import 'package:leancode_lint/config.dart';
import 'package:leancode_lint/lints/add_cubit_suffix_for_cubits.dart';
import 'package:leancode_lint/lints/avoid_conditional_hooks.dart';
import 'package:leancode_lint/lints/avoid_single_child_in_multi_child_widget.dart';
import 'package:leancode_lint/lints/catch_parameter_names.dart';
import 'package:leancode_lint/lints/constructor_parameters_and_fields_should_have_the_same_order.dart';
import 'package:leancode_lint/lints/hook_widget_does_not_use_hooks.dart';
import 'package:leancode_lint/lints/prefix_widgets_returning_slivers.dart';
import 'package:leancode_lint/lints/start_comments_with_space.dart';
import 'package:leancode_lint/lints/use_align.dart';
import 'package:leancode_lint/lints/use_dedicated_media_query_methods.dart';
import 'package:leancode_lint/lints/use_design_system_item.dart';
import 'package:leancode_lint/lints/use_padding.dart';

export 'package:leancode_lint/config.dart';

/// Analyzer plugin implementation for `leancode_lint`.
///
/// Consumers that want to configure the lints programmatically should import
/// `package:leancode_lint/plugin.dart` and instantiate [LeanCodeLintPlugin]
/// from their own plugin package.
final class LeanCodeLintPlugin extends Plugin {
  LeanCodeLintPlugin({this.name = 'leancode_lint', this.config = const .new()});

  @override
  final String name;

  final LeanCodeLintConfig config;

  @override
  void register(PluginRegistry registry) {
    UseDesignSystemItem.fromConfig(
      config,
    ).forEach(registry.registerWarningRule);
    registry
      ..registerWarningRule(StartCommentsWithSpace())
      ..registerWarningRule(PrefixWidgetsReturningSlivers(config: config))
      ..registerFixForRule(
        StartCommentsWithSpace.code,
        AddStartingSpaceToComment.new,
      )
      ..registerWarningRule(AddCubitSuffixForYourCubits())
      ..registerWarningRule(CatchParameterNames(config: config))
      ..registerWarningRule(AvoidConditionalHooks())
      ..registerWarningRule(HookWidgetDoesNotUseHooks())
      ..registerFixForRule(
        HookWidgetDoesNotUseHooks.code,
        ConvertHookWidgetToStatelessWidget.new,
      )
      // TODO: disabled by default until stabilized. Add documentation.
      ..registerLintRule(ConstructorParametersAndFieldsShouldHaveTheSameOrder())
      ..registerWarningRule(AvoidSingleChildInMultiChildWidgets())
      ..registerWarningRule(UseAlign())
      ..registerFixForRule(UseAlign.code, UseAlignFix.new)
      ..registerWarningRule(UsePadding())
      ..registerFixForRule(UsePadding.code, UsePaddingFix.new)
      ..registerWarningRule(UseDedicatedMediaQueryMethods())
      ..registerFixForRule(
        UseDedicatedMediaQueryMethods.code,
        ReplaceMediaQueryOfWithDedicatedMethodFix.new,
      )
      // TODO: uncomment when `prefer_center_over_align` is migrated
      // ..registerAssist(PreferCenterOverAlign())
      ..registerAssist(ConvertRecordIntoNominalType.new)
      ..registerAssist(ConvertPositionalToNamedFormal.new)
      ..registerAssist(ConvertIterableMapToCollectionFor.new);
  }
}
