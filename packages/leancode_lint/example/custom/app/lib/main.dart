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
