// This is the entrypoint of our custom linter
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

PluginBase createPlugin() => _ExampleLinter();

/// A plugin class is used to list all the assists/lints defined by a plugin.
class _ExampleLinter extends PluginBase {
  /// We list all the custom warnings/infos/errors
  @override
  List<LintRule> getLintRules(CustomLintConfigs configs) => [
        const MyCustomLintCode(),
      ];
}

class MyCustomLintCode extends DartLintRule {
  const MyCustomLintCode() : super(code: _code);

  /// Metadata about the warning that will show-up in the IDE.
  /// This is used for `// ignore: code` and enabling/disabling the lint
  static const _code = LintCode(
    name: 'my_custom_lint_code',
    problemMessage: 'This is the description of our custom lint',
  );

  @override
  void run(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
  ) {
    // Our lint will highlight all variable declarations with our custom warning.
    context.registry.addVariableDeclaration((node) {
      // "node" exposes metadata about the variable declaration. We could
      // check "node" to show the lint only in some conditions.

      // This line tells custom_lint to render a waring at the location of "node".
      // And the warning shown will use our `code` variable defined above as description.
      reporter.reportErrorForNode(code, node);
    });
  }
}
