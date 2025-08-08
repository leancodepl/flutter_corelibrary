// ignore_for_file: avoid_redundant_argument_values

import 'package:flutter/material.dart';

class UseAlignTest {
  void test() {
    // expect_lint: use_align
    Container(alignment: Alignment.center, child: const SizedBox());

    // expect_lint: use_align
    Container(alignment: Alignment.centerLeft, child: const SizedBox());

    // expect_lint: use_align
    Container(
      alignment: Alignment.topCenter,
      key: const Key('key'),
      child: const SizedBox(),
    );

    Container(
      alignment: Alignment.center,
      color: Colors.red,
      child: const SizedBox(),
    );

    Container(color: Colors.red, child: const SizedBox());

    // expect_lint: use_align
    Container(alignment: Alignment.center);

    const Align(alignment: Alignment.bottomCenter, child: SizedBox());

    // expect_lint: use_align
    Container(alignment: null, child: const SizedBox());
  }
}
