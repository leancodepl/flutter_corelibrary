final class const LeanCodeLintConfig({
  /// Used by some rules (e.g. `prefix_widgets_returning_slivers`) to match
  /// project-specific prefixes.
  final String? applicationPrefix,

  /// Configuration for the `use_design_system_item` rule.
  /// Defines which types are forbidden and what to use instead.
  ///
  /// Map key is the preferred item name (e.g. `LftText`) and map value is the
  /// list of forbidden items (e.g. `Text` from `flutter`).
  final Map<String, List<DesignSystemForbiddenItem>>
      designSystemItemReplacements =
      const {},

  /// Configuration for the `catch_parameter_names` rule.
  final CatchParameterNamesConfig catchParameterNames = const .new(),

  /// Configuration for the `bloc_related_class_naming` rule.
  final BlocRelatedClassNamingConfig blocRelatedClassNaming = const .new(),

  /// Configuration for the `cognitive_complexity` rule.
  final CognitiveComplexityConfig cognitiveComplexity = const .new(),

  /// Configuration for the `prefer_dot_shorthand` rule.
  final PreferDotShorthandConfig preferDotShorthand = const .new(),
});

/// Configuration for the `bloc_related_class_naming` rule.
///
/// Each suffix is appended to the BLoC/Cubit subject name (the part before
/// `Bloc` or `Cubit`) to form the expected class name.
///
/// For example, for `FooBloc` the default expected names are:
/// - state → `FooState`
/// - event → `FooEvent`
/// - presentation event → `FooPresentationEvent`
class const BlocRelatedClassNamingConfig({
  final String stateSuffix = 'State',
  final String eventSuffix = 'Event',
  final String presentationEventSuffix = 'PresentationEvent',
});

/// Configuration for the `cognitive_complexity` rule.
///
/// [maximum] is the highest cognitive complexity a function may have. The
/// default, 15, is SonarSource's and Biome's.
class const CognitiveComplexityConfig({final int maximum = 15});

/// Configuration for the `prefer_dot_shorthand` rule: the kinds of member it
/// reports, all of them by default.
///
/// - [unnamedConstructors]: `.new(1)` for `Key(1)`
/// - [namedConstructors]: `.named(1)` for `Key.named(1)`
/// - [staticMembers]: `.parse(s)` for `int.parse(s)`, `.infinity` for
///   `double.infinity`
/// - [enumValues]: `.center` for `Alignment.center`
class const PreferDotShorthandConfig({
  final bool unnamedConstructors = true,
  final bool namedConstructors = true,
  final bool staticMembers = true,
  final bool enumValues = true,
});

class const CatchParameterNamesConfig({
  final String exception = 'err',
  final String stackTrace = 'st',
});

class const DesignSystemForbiddenItem({
  required final String name,
  required final String packageName,
});
