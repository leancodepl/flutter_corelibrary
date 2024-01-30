import 'dart:math';

import 'package:flutter/material.dart';

class ColumnIsMarked extends StatelessWidget {
  const ColumnIsMarked({super.key});

  @override
  Widget build(BuildContext context) {
    // expect_lint: avoid_single_child_in_multi_child_widgets
    return Column(
      children: [
        Container(),
      ],
    );
  }
}

class RowIsMarked extends StatelessWidget {
  const RowIsMarked({super.key});

  @override
  Widget build(BuildContext context) {
    // expect_lint: avoid_single_child_in_multi_child_widgets
    return Row(
      children: [
        Container(),
      ],
    );
  }
}

class FlexIsMarked extends StatelessWidget {
  const FlexIsMarked({super.key});

  @override
  Widget build(BuildContext context) {
    // expect_lint: avoid_single_child_in_multi_child_widgets
    return Flex(
      direction: Axis.horizontal,
      children: [
        Container(),
      ],
    );
  }
}

class WrapIsMarked extends StatelessWidget {
  const WrapIsMarked({super.key});

  @override
  Widget build(BuildContext context) {
    // expect_lint: avoid_single_child_in_multi_child_widgets
    return Wrap(
      children: [
        Container(),
      ],
    );
  }
}

class StackIsMarked extends StatelessWidget {
  const StackIsMarked({super.key});

  @override
  Widget build(BuildContext context) {
    // expect_lint: avoid_single_child_in_multi_child_widgets
    return Stack(
      children: [
        Container(),
      ],
    );
  }
}

class SliverMainAxisGroupIsMarked extends StatelessWidget {
  const SliverMainAxisGroupIsMarked({super.key});

  @override
  Widget build(BuildContext context) {
    // expect_lint: avoid_single_child_in_multi_child_widgets
    return const SliverMainAxisGroup(
      slivers: [
        SliverToBoxAdapter(),
      ],
    );
  }
}

class SliverCrossAxisGroupIsMarked extends StatelessWidget {
  const SliverCrossAxisGroupIsMarked({super.key});

  @override
  Widget build(BuildContext context) {
    // expect_lint: avoid_single_child_in_multi_child_widgets
    return const SliverCrossAxisGroup(
      slivers: [
        SliverToBoxAdapter(),
      ],
    );
  }
}

class ZeroChildrenIsNotMarked extends StatelessWidget {
  const ZeroChildrenIsNotMarked({super.key});

  @override
  Widget build(BuildContext context) {
    return const Wrap();
  }
}

class ManyChildrenIsNotMarked extends StatelessWidget {
  const ManyChildrenIsNotMarked({super.key});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      children: [
        Container(),
        Container(),
        Container(),
      ],
    );
  }
}

class CollectionForIsMany extends StatelessWidget {
  const CollectionForIsMany({super.key});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      children: [
        for (var i = 0; i < 3; i++) Container(),
      ],
    );
  }
}

class ListSpreadIsMany extends StatelessWidget {
  const ListSpreadIsMany({super.key});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      children: [
        ...[
          for (var i = 0; i < 3; i++) Container(),
        ],
      ],
    );
  }
}

class NotCollectionLiteralIsMany extends StatelessWidget {
  const NotCollectionLiteralIsMany({super.key});

  @override
  Widget build(BuildContext context) {
    final children = [
      Container(),
      Container(),
      Container(),
    ];

    return Wrap(
      children: children,
    );
  }
}

class CollectionIfIsMarked extends StatelessWidget {
  const CollectionIfIsMarked({super.key});

  @override
  Widget build(BuildContext context) {
    // expect_lint: avoid_single_child_in_multi_child_widgets
    return Wrap(
      children: [
        if (Random().nextBool())
          if (Random().nextBool())
            if (Random().nextBool()) Container(),
      ],
    );
  }
}

class CollectionIfElseIsMarked extends StatelessWidget {
  const CollectionIfElseIsMarked({super.key});

  @override
  Widget build(BuildContext context) {
    // expect_lint: avoid_single_child_in_multi_child_widgets
    return Wrap(
      children: [
        if (Random().nextBool())
          if (Random().nextBool()) Container() else Container(),
      ],
    );
  }
}

class CollectionIfIsNotMarkedWhenProducingMany extends StatelessWidget {
  const CollectionIfIsNotMarkedWhenProducingMany({super.key});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      children: [
        if (Random().nextBool())
          if (Random().nextBool())
            if (Random().nextBool())
              for (var i = 0; i < 3; i++) Container(),
      ],
    );
  }
}

class CollectionIfIsNotMarkedWhenProducingManyElse extends StatelessWidget {
  const CollectionIfIsNotMarkedWhenProducingManyElse({super.key});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      children: [
        if (Random().nextBool())
          if (Random().nextBool())
            if (Random().nextBool())
              Container()
            else
              for (var i = 0; i < 3; i++) Container(),
      ],
    );
  }
}
