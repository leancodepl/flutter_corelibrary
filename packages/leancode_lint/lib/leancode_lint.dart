import 'package:custom_lint_builder/custom_lint_builder.dart';
import 'package:leancode_lint/assists/convert_iterable_map_to_collection_for.dart';
import 'package:leancode_lint/assists/convert_positional_to_named_formal.dart';
import 'package:leancode_lint/assists/convert_record_into_nominal_type.dart';
import 'package:leancode_lint/lints/add_cubit_suffix_for_cubits.dart';
import 'package:leancode_lint/lints/avoid_conditional_hooks.dart';
import 'package:leancode_lint/lints/avoid_single_child_in_multi_child_widget.dart';
import 'package:leancode_lint/lints/bloc_class_modifiers.dart';
import 'package:leancode_lint/lints/bloc_related_classes_equatable.dart';
import 'package:leancode_lint/lints/bloc_related_classes_naming.dart';
import 'package:leancode_lint/lints/bloc_subclasses_naming.dart';
import 'package:leancode_lint/lints/catch_parameter_names.dart';
import 'package:leancode_lint/lints/constructor_parameters_and_fields_should_have_the_same_order.dart';
import 'package:leancode_lint/lints/hook_widget_does_not_use_hooks.dart';
import 'package:leancode_lint/lints/prefix_widgets_returning_slivers.dart';
import 'package:leancode_lint/lints/start_comments_with_space.dart';
import 'package:leancode_lint/lints/use_design_system_item.dart';
import 'package:leancode_lint/lints/use_equatable_mixin.dart';

PluginBase createPlugin() => _Linter();

class _Linter extends PluginBase {
  @override
  List<LintRule> getLintRules(CustomLintConfigs configs) => [
    StartCommentsWithSpace(),
    ...UseDesignSystemItem.getRulesListFromConfigs(configs),
    PrefixWidgetsReturningSlivers.fromConfigs(configs),
    AddCubitSuffixForYourCubits(),
    CatchParameterNames(),
    AvoidConditionalHooks(),
    HookWidgetDoesNotUseHooks(),
    ConstructorParametersAndFieldsShouldHaveTheSameOrder(),
    AvoidSingleChildInMultiChildWidgets(),
    const BlocRelatedClassNaming(),
    const UseEquatableMixin(),
    const BlocSubclassesNaming(),
    const BlocClassModifiers(),
    const BlocRelatedClassesEquatable(),
  ];

  @override
  List<Assist> getAssists() => [
    ConvertRecordIntoNominalType(),
    ConvertPositionalToNamedFormal(),
    ConvertIterableMapToCollectionFor(),
  ];
}
