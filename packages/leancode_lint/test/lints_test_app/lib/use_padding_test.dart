// Ignored for test purposes
// ignore_for_file: avoid_redundant_argument_values

import 'package:flutter/material.dart';

// dart format off
class UsePaddingTest {
  void test() {
    // expect_lint: use_padding
    Container(
      margin: const EdgeInsets.all(10),
      child: const SizedBox(),
    );

    // expect_lint: use_padding
    Container(
      margin: const EdgeInsets.all(10),
      child: const SizedBox(),
    );

    // expect_lint: use_padding
    Container(
      margin: const EdgeInsets.all(10),
      key: const Key('key'),
      child: const SizedBox(),
    );

    Container(
      margin: const EdgeInsets.all(10),
      color: Colors.red,
      child: const SizedBox(),
    );

    Container(
      color: Colors.red,
      child: const SizedBox(),
    );

    // expect_lint: use_padding
    Container(
      margin: const EdgeInsets.all(10),
    );

    const Padding(
      padding: EdgeInsets.all(10),
      child: SizedBox(),
    );

    Container(
      margin: null,
      child: const SizedBox(),
    );

    const EdgeInsets? nullablePadding = null;
    Container(
      margin: nullablePadding,
      child: const SizedBox(),
    );
  }
}
// dart format on
