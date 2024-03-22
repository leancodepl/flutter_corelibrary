// ignore_for_file: unused_local_variable
// ignore_for_file: avoid_string_literals_in_widgets

import 'package:flutter/material.dart';

class SampleWidget extends StatelessWidget {
  const SampleWidget({super.key});

  @override
  Widget build(BuildContext context) {
    // expect_lint: use_design_system_item_LftText
    Text? text;

    // expect_lint: use_design_system_item_LftScaffold
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // expect_lint: use_design_system_item_LftText
        title: const Text('abc'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // expect_lint: use_design_system_item_LftText
            RichText(text: const TextSpan(text: 'abc')),
            const SizedBox(),
          ],
        ),
      ),
    );
  }
}

class LftScaffold extends StatelessWidget {
  const LftScaffold({super.key});

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}

class LftText extends StatelessWidget {
  const LftText({super.key});

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
