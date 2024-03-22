// ignore_for_file: avoid_print

import 'package:flutter/material.dart';

class MyStatelessWidget extends StatelessWidget {
  const MyStatelessWidget({super.key});

  // expect_lint: avoid_string_literals_in_widgets
  final aStringVariable = 'This is an hardcoded text';

  // expect_lint: avoid_string_literals_in_widgets
  final anInterpolatedStringVariable = 'This is a number: ${1}';

  @override
  Widget build(BuildContext context) {
    try {
      // expect_lint: avoid_string_literals_in_widgets
      print('Executing something...');
      _doSomethingBad();
    } catch (err) {
      print('Something bad happened.');
    }

    return Column(
      children: [
        // expect_lint: avoid_string_literals_in_widgets
        const WidgetWithText('This is an hardcoded text'),
        WidgetWithText(aStringVariable),
      ],
    );
  }

  void _doSomethingBad() {
    throw Exception('Bad stuff happening');
  }
}

class WidgetWithText extends StatelessWidget {
  const WidgetWithText(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
