import 'package:analysis_server_plugin/plugin.dart';
import 'package:analysis_server_plugin/registry.dart';
import 'package:leancode_lint/lints/add_cubit_suffix_for_cubits.dart';
import 'package:leancode_lint/lints/avoid_conditional_hooks.dart';
import 'package:leancode_lint/lints/avoid_single_child_in_multi_child_widget.dart';
import 'package:leancode_lint/lints/catch_parameter_names.dart';
import 'package:leancode_lint/lints/hook_widget_does_not_use_hooks.dart';
import 'package:leancode_lint/lints/start_comments_with_space.dart';

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
      ..registerWarningRule(StartCommentsWithSpace()..registerFixes(registry))
      ..registerWarningRule(AddCubitSuffixForYourCubits())
      ..registerWarningRule(CatchParameterNames())
      ..registerWarningRule(AvoidConditionalHooks())
      ..registerWarningRule(
        HookWidgetDoesNotUseHooks()..registerFixes(registry),
      )
      ..registerWarningRule(AvoidSingleChildInMultiChildWidgets());
  }
}
