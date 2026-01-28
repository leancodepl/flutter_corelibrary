final class LeanCodeLintConfig {
  const LeanCodeLintConfig({
    this.applicationPrefix,
    this.designSystemItemReplacements = const {},
    this.catchParameterNames = const .new(),
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
