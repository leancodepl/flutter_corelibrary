import 'package:flutter/material.dart';

/// Design system text widget.
class AppText extends StatelessWidget {
  const AppText(this.data, {super.key});

  final String data;

  @override
  Widget build(BuildContext context) {
    // When ignoring custom lints, use the prefix with the package name.
    // If you provide a custom name to the `LeanCodeLintPlugin`, use it here:
    // ignore: my_lints/use_design_system_item_AppText
    return Text(data);
  }
}

/// Design system scaffold widget.
class AppScaffold extends StatelessWidget {
  const AppScaffold({super.key, this.appBar, required this.body});

  final PreferredSizeWidget? appBar;
  final Widget body;

  @override
  Widget build(BuildContext context) {
    // Ignores are case-insensitive:
    // ignore: my_lints/use_design_system_item_appscaffold
    return Scaffold(appBar: appBar, body: body);
  }
}
