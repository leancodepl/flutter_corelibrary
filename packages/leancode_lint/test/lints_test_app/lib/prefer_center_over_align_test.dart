// Ignore for test purposes
// ignore_for_file: avoid_redundant_argument_values, use_named_constants, prefer_int_literals

import 'package:flutter/material.dart';

class PreferCenterOverAlignTest {
  void test() {
    // expect_lint: prefer_center_over_align
    const Align(child: SizedBox());

    // expect_lint: prefer_center_over_align
    const Align(alignment: Alignment(0, 0), child: SizedBox());

    // expect_lint: prefer_center_over_align
    const Align(alignment: Alignment(0.0, 0.0), child: SizedBox());

    // expect_lint: prefer_center_over_align
    const Align(alignment: Alignment.center, child: SizedBox());

    // expect_lint: prefer_center_over_align
    const Align(
      alignment: Alignment.center,
      key: Key('key'),
      child: SizedBox(),
    );

    // expect_lint: prefer_center_over_align
    const Align(alignment: Alignment(0, 0), key: Key('key'), child: SizedBox());

    // expect_lint: prefer_center_over_align
    const Align(
      alignment: Alignment(0.0, 0.0),
      widthFactor: 0.5,
      heightFactor: 1,
      child: SizedBox(),
    );

    const Align(
      alignment: Alignment.topRight,
      key: Key('key'),
      child: SizedBox(),
    );

    const Align(
      alignment: Alignment.topRight,
      widthFactor: 1,
      heightFactor: 1,
      child: SizedBox(),
    );

    const Align(alignment: Alignment.centerLeft, child: SizedBox());

    const Center(child: SizedBox());

    const Align(alignment: Alignment.bottomCenter, child: SizedBox());
  }
}
