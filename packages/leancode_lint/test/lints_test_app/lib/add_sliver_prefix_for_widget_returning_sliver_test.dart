import 'dart:math';

import 'package:flutter/material.dart';

// expect_lint: add_sliver_prefix_for_widget_returning_sliver
class WidgetReturningSliverFromInternalBlocks extends StatelessWidget {
  const WidgetReturningSliverFromInternalBlocks({super.key});

  @override
  Widget build(BuildContext context) {
    if (Random().nextBool()) {
      return const SliverToBoxAdapter();
    } else {
      return const SliverToBoxAdapter();
    }
  }
}

abstract class WidgetImpostorInterface {
  Widget build(BuildContext context);
}

// Should not throw warning since it's not real widget
class WidgetImpostor extends WidgetImpostorInterface {
  WidgetImpostor();

  @override
  Widget build(BuildContext context) {
    return const SliverToBoxAdapter();
  }
}

class NotPrefixedWidgetReturningSliver extends StatelessWidget {
  const NotPrefixedWidgetReturningSliver({super.key});

// expect_lint: add_sliver_prefix_for_widget_returning_sliver
  @override
  Widget build(BuildContext context) {
    return const SliverToBoxAdapter();
  }
}

// Should not throw warning since it's prefixed
class SliverPrefixedWidgetReturningSliver extends StatelessWidget {
  const SliverPrefixedWidgetReturningSliver({super.key});

  @override
  Widget build(BuildContext context) {
    return const SliverToBoxAdapter();
  }
}

// Should not throw warning since it's not returning sliver
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
