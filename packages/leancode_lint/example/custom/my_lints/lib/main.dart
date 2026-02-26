import 'package:leancode_lint/plugin.dart';

/// Custom plugin with project-specific configuration.
///
/// - Uses `error` and `stackTrace` for catch parameters
/// - Configures design system replacements (e.g. use AppText instead of Text)
final plugin = LeanCodeLintPlugin(
  name: 'my_lints',
  config: const LeanCodeLintConfig(
    catchParameterNames: CatchParameterNamesConfig(
      exception: 'error',
      stackTrace: 'stackTrace',
    ),
    designSystemItemReplacements: {
      'AppText': [
        DesignSystemForbiddenItem(name: 'Text', packageName: 'flutter'),
        DesignSystemForbiddenItem(name: 'RichText', packageName: 'flutter'),
      ],
      'AppScaffold': [
        DesignSystemForbiddenItem(name: 'Scaffold', packageName: 'flutter'),
      ],
    },
  ),
);
