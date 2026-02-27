final class LeanCodeLintConfig {
  const LeanCodeLintConfig({
    this.applicationPrefix,
    this.designSystemItemReplacements = const {},
    this.catchParameterNames = const .new(),
    this.blocRelatedClassNaming = const .new(),
  });

  /// Used by some rules (e.g. `prefix_widgets_returning_slivers`) to match
  /// project-specific prefixes.
  final String? applicationPrefix;

  /// Configuration for the `use_design_system_item` rule.
  /// Defines which types are forbidden and what to use instead.
  ///
  /// Map key is the preferred item name (e.g. `LftText`) and map value is the
  /// list of forbidden items (e.g. `Text` from `flutter`).
  final Map<String, List<DesignSystemForbiddenItem>>
  designSystemItemReplacements;

  /// Configuration for the `catch_parameter_names` rule.
  final CatchParameterNamesConfig catchParameterNames;

  /// Configuration for the `bloc_related_class_naming` rule.
  final BlocRelatedClassNamingConfig blocRelatedClassNaming;
}

/// Configuration for the `bloc_related_class_naming` rule.
///
/// Each suffix is appended to the BLoC/Cubit subject name (the part before
/// `Bloc` or `Cubit`) to form the expected class name.
///
/// For example, for `FooBloc` the default expected names are:
/// - state → `FooState`
/// - event → `FooEvent`
/// - presentation event → `FooPresentationEvent`
class BlocRelatedClassNamingConfig {
  const BlocRelatedClassNamingConfig({
    this.stateSuffix = 'State',
    this.eventSuffix = 'Event',
    this.presentationEventSuffix = 'PresentationEvent',
  });

  final String stateSuffix;
  final String eventSuffix;
  final String presentationEventSuffix;
}

class CatchParameterNamesConfig {
  const CatchParameterNamesConfig({
    this.exception = 'err',
    this.stackTrace = 'st',
  });

  final String exception;
  final String stackTrace;
}

class DesignSystemForbiddenItem {
  const DesignSystemForbiddenItem({
    required this.name,
    required this.packageName,
  });

  final String name;
  final String packageName;
}
