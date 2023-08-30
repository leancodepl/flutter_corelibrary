// ignore_for_file: unused_local_variable

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
          ],
        ),
      ),
    );
  }
}
