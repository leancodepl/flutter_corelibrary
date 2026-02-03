part of '../mock_libraries.dart';

mixin MockHooksRiverpod on AnalysisRuleTest {
  @override
  void setUp() {
    newPackage('hooks_riverpod').addFile('lib/hooks_riverpod.dart', '''
import 'package:flutter/material.dart';

class WidgetRef {}

abstract class ConsumerWidget extends StatefulWidget {
  Widget build(BuildContext context, WidgetRef ref);

  @override
  State<ConsumerWidget> createState() => throw UnimplementedError();
}

abstract class HookConsumerWidget extends ConsumerWidget {
  const HookConsumerWidget({super.key});
}

typedef ConsumerBuilder =
    Widget Function(BuildContext context, WidgetRef ref, Widget? child);

class HookConsumer extends HookConsumerWidget {
  const HookConsumer({required ConsumerBuilder builder});
}
''');
    super.setUp();
  }
}
