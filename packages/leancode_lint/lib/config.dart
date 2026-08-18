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

class const CatchParameterNamesConfig({
  final String exception = 'err',
  final String stackTrace = 'st',
});

class const DesignSystemForbiddenItem({
  required final String name,
  required final String packageName,
});
