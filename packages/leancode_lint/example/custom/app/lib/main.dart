import 'package:custom_example_app/design_system.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const CustomExampleApp());
}

Future<void> fetchData() async {
  try {
    await Future<void>.delayed(const Duration(seconds: 1));
  } catch (error, stackTrace) {
    debugPrint('$error\n$stackTrace');
  }
}

class const CustomExampleApp({super.key}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Custom Config Example',
      theme: ThemeData(colorScheme: .fromSeed(seedColor: Colors.green)),
      home: const CustomExampleHome(),
    );
  }
}

// Reported: "Color is forbidden within this design system."
Widget explicitColor() => Container(color: const Color(0xFF00FF00));
// Not reported, but it still builds a plain Color.
Widget shorthandColor() => Container(color: const .new(0xFF00FF00));
// Not reported: named constructor shorthand.
Widget namedShorthandColor() =>
    Container(color: const .fromARGB(255, 0, 255, 0));

class const CustomExampleHome({super.key}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: AppBar(title: const AppText('leancode_lint custom config')),
      body: const Center(
        child: ElevatedButton(
          onPressed: fetchData,
          child: AppText('Trigger try-catch'),
        ),
      ),
    );
  }
}
