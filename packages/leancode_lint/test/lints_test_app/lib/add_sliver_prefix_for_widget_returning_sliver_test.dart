import 'package:flutter/material.dart';

// expect_lint: add_sliver_prefix_for_widget_returning_sliver
class WidgetReturningSliverFromInternalBlocks extends StatelessWidget {
  const WidgetReturningSliverFromInternalBlocks({super.key});

  @override
  Widget build(BuildContext context) {
    // ignore: literal_only_boolean_expressions
    if (true) {
      return const SliverToBoxAdapter();
      // ignore: dead_code
    } else {
      return const SliverToBoxAdapter();
    }
  }
}

class WidgetImpostor {
  WidgetImpostor();

  @override
  // ignore: override_on_non_overriding_member
  Widget build(BuildContext context) {
    return const SliverToBoxAdapter();
  }
}

// expect_lint: add_sliver_prefix_for_widget_returning_sliver
class NotPrefixedWidgetReturningSliver extends StatelessWidget {
  const NotPrefixedWidgetReturningSliver({super.key});

  @override
  Widget build(BuildContext context) {
    return const SliverToBoxAdapter();
  }
}

class NotPrefixedWidgetNotReturningSliver extends StatelessWidget {
  const NotPrefixedWidgetNotReturningSliver({super.key});

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) {
        return const SizedBox();
      },
    );
  }
}
