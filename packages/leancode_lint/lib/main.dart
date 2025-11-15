import 'package:analysis_server_plugin/plugin.dart';
import 'package:analysis_server_plugin/registry.dart';
import 'package:leancode_lint/assists/convert_iterable_map_to_collection_for.dart';
import 'package:leancode_lint/assists/convert_positional_to_named_formal.dart';
import 'package:leancode_lint/assists/convert_record_into_nominal_type.dart';
import 'package:leancode_lint/helpers.dart';
import 'package:leancode_lint/lints/avoid_conditional_hooks.dart';
import 'package:leancode_lint/lints/avoid_single_child_in_multi_child_widget.dart';
import 'package:leancode_lint/lints/catch_parameter_names.dart';
import 'package:leancode_lint/lints/constructor_parameters_and_fields_should_have_the_same_order.dart';
import 'package:leancode_lint/lints/hook_widget_does_not_use_hooks.dart';
import 'package:leancode_lint/lints/missing_cubit_suffix.dart';
import 'package:leancode_lint/lints/prefix_widgets_returning_slivers.dart';
import 'package:leancode_lint/lints/start_comments_with_space.dart';
import 'package:leancode_lint/lints/use_align.dart';
import 'package:leancode_lint/lints/use_dedicated_media_query_methods.dart';
import 'package:leancode_lint/lints/use_design_system_item.dart';
import 'package:leancode_lint/lints/use_padding.dart';

final plugin = _Linter();

class _Linter extends Plugin {
  // @override
  // List<LintRule> getLintRules(CustomLintConfigs configs) => [
  //   const ConstructorParametersAndFieldsShouldHaveTheSameOrder(),
  //   const PreferCenterOverAlign(),
  // ];

  @override
  String get name => 'leancode_lint';

  @override
  void register(PluginRegistry registry) {
    registry
      ..registerWarningRule(UseDesignSystemItem())
      ..registerAssist(ConvertRecordIntoNominalType.new)
      ..registerAssist(ConvertPositionalToNamedFormal.new)
      ..registerAssist(ConvertIterableMapToCollectionFor.new)
      ..registerWarningRule(StartCommentsWithSpace())
      ..registerWarningRule(PrefixWidgetsReturningSlivers())
      ..registerFixForRule(
        StartCommentsWithSpace.code,
        AddStartingSpaceToComment.new,
      )
      ..registerWarningRule(MissingCubitSuffix())
      ..registerWarningRule(CatchParameterNames())
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
      ..registerFixForRule(
        UseAlign.code,
        ChangeWidgetNameFix.producerGeneratorFor('Align'),
      )
      ..registerWarningRule(UsePadding())
      ..registerFixForRule(UsePadding.code, UsePaddingFix.new)
      ..registerWarningRule(UseDedicatedMediaQueryMethods())
      ..registerFixForRule(
        UseDedicatedMediaQueryMethods.code,
        ReplaceMediaQueryOfWithDedicatedMethodFix.new,
      );
  }
}
