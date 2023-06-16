import 'dart:math';

import 'package:enhanced_gradients/enhanced_gradients.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  List<Color> _colors = [];
  List<double>? _stops;

  final _random = Random(42);

  void _randomizeGradient() {
    final length = _random.nextInt(2) + 2;
    setState(() {
      _colors = List.generate(
        length,
        (index) => Color.fromARGB(
          _random.nextInt(256),
          _random.nextInt(256),
          _random.nextInt(256),
          _random.nextInt(256),
        ),
      );
      final useStops = _random.nextDouble() > 0.2;
      if (useStops) {
        _stops = List<double>.generate(length, (index) => _random.nextDouble())
          ..sort();
      } else {
        _stops = null;
      }
    });
  }

  @override
  void initState() {
    super.initState();

    _randomizeGradient();
  }

  @override
  Widget build(BuildContext context) {
    final gradient = LinearGradient(colors: _colors, stops: _stops);

    print('$_colors, $_stops');

    return MaterialApp(
      home: Scaffold(
        floatingActionButton: FloatingActionButton(
          onPressed: _randomizeGradient,
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _GradientPreview(
              title: 'Regular LinearGradient',
              gradient: gradient,
            ),
            const SizedBox(height: 16),
            _GradientPreview(
              title: 'Enhanced LinearGradient',
              gradient: gradient.enhanced(),
            ),
          ],
        ),
      ),
    );
  }
}

class _GradientPreview extends StatelessWidget {
  const _GradientPreview({
    required this.title,
    required this.gradient,
  });

  final String title;
  final Gradient gradient;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(title),
        const SizedBox(height: 8),
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: gradient,
          ),
          child: const SizedBox(
            width: double.infinity,
            height: 48,
          ),
        ),
      ],
    );
  }
}
