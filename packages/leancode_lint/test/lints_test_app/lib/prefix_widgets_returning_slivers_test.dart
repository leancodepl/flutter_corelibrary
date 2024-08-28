// for tests
// ignore_for_file: unused_element

import 'dart:math';

import 'package:flutter/material.dart';

// expect_lint: prefix_widgets_returning_slivers
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

class Stateful extends StatefulWidget {
  const Stateful({super.key});

  @override
  State<Stateful> createState() => _StatefulState();
}

// expect_lint: prefix_widgets_returning_slivers
class _StatefulState extends State<Stateful> {
  @override
  Widget build(BuildContext context) {
    return const SliverToBoxAdapter();
  }
}

abstract class WidgetImpostorInterface {
  Widget build(BuildContext context);
}

// Should not report warning since it's not real widget
class WidgetImpostor extends WidgetImpostorInterface {
  WidgetImpostor();

  @override
  Widget build(BuildContext context) {
    return const SliverToBoxAdapter();
  }
}

// expect_lint: prefix_widgets_returning_slivers
class NotPrefixedWidgetReturningSliver extends StatelessWidget {
  const NotPrefixedWidgetReturningSliver({super.key});

  @override
  Widget build(BuildContext context) {
    return const SliverToBoxAdapter();
  }
}

// Should not report warning since it's prefixed
class SliverPrefixedWidgetReturningSliver extends StatelessWidget {
  const SliverPrefixedWidgetReturningSliver({super.key});

  @override
  Widget build(BuildContext context) {
    return const SliverToBoxAdapter();
  }
}

// Should not report warning since it's prefixed (with app prefix)
class LncdSliverPrefixedWidgetReturningSliver extends StatelessWidget {
  const LncdSliverPrefixedWidgetReturningSliver({super.key});

  @override
  Widget build(BuildContext context) {
    return const SliverToBoxAdapter();
  }
}

// Should not report warning since it's prefixed (with app prefix + private)
class _LncdSliverPrefixedWidgetReturningSliver extends StatelessWidget {
  const _LncdSliverPrefixedWidgetReturningSliver({super.key});

  @override
  Widget build(BuildContext context) {
    return const SliverToBoxAdapter();
  }
}

// expect_lint: prefix_widgets_returning_slivers
class LncdReturningAppPrefixedSliver extends StatelessWidget {
  const LncdReturningAppPrefixedSliver({super.key});

  @override
  Widget build(BuildContext context) {
    return const LncdSliverPrefixedWidgetReturningSliver();
  }
}

// Should not report warning since it's not returning sliver
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
