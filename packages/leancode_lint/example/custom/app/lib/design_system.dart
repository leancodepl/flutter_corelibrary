import 'package:flutter/material.dart';

/// Design system text widget.
class const AppText(final String data, {super.key}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // When ignoring custom lints, use the prefix with the package name.
    // If you provide a custom name to the `LeanCodeLintPlugin`, use it here:
    // ignore: my_lints/use_design_system_item_AppText
    return Text(data);
  }
}

/// Design system scaffold widget.
class const AppScaffold({
  super.key,
  final PreferredSizeWidget? appBar,
  required final Widget body,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Ignores are case-insensitive:
    // ignore: my_lints/use_design_system_item_appscaffold
    return Scaffold(appBar: appBar, body: body);
  }
}
