import 'package:flutter/material.dart';

class UsePaddingTest {
  void test() {
    // expect_lint: use_padding
    Container(padding: const EdgeInsets.all(10), child: const SizedBox());

    // expect_lint: use_padding
    Container(padding: const EdgeInsets.all(10), child: const SizedBox());

    // expect_lint: use_padding
    Container(
      padding: const EdgeInsets.all(10),
      key: const Key('key'),
      child: const SizedBox(),
    );

    Container(
      padding: const EdgeInsets.all(10),
      color: Colors.red,
      child: const SizedBox(),
    );

    Container(color: Colors.red, child: const SizedBox());

    // expect_lint: use_padding
    Container(padding: const EdgeInsets.all(10));

    const Padding(padding: EdgeInsets.all(10), child: SizedBox());
  }
}
