import 'package:flutter/material.dart';

void main() {
  runApp(const DefaultExampleApp());
}

Future<void> fetchData() async {
  try {
    await Future<void>.delayed(const Duration(seconds: 1));
  } catch (err, st) {
    debugPrint('$err\n$st');
  }
}

class const DefaultExampleApp({super.key}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Default Config Example',
      theme: ThemeData(colorScheme: .fromSeed(seedColor: Colors.blue)),
      home: const DefaultExampleHome(),
    );
  }
}

class const DefaultExampleHome({super.key}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('leancode_lint default config')),
      body: const Center(
        child: ElevatedButton(
          onPressed: fetchData,
          child: Text('Trigger try-catch'),
        ),
      ),
    );
  }
}
