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
        _stops![0] = 0;
        _stops![length - 1] = 1;
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
    final linearGradient = LinearGradient(
      colors: _colors,
      stops: _stops,
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    );
    final radialGradient = RadialGradient(colors: _colors, stops: _stops);
    final sweepGradient = SweepGradient(colors: _colors, stops: _stops);

    return MaterialApp(
      home: Scaffold(
        floatingActionButton: FloatingActionButton(
          onPressed: _randomizeGradient,
          child: const Icon(Icons.shuffle),
        ),
        body: ListView(
          children: [
            const SizedBox(height: 24),
            const Text(
              'Regular gradient (first half) vs Enhanced gradient (second half)',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Center(
              child: _LinearGradientComparison(
                gradientA: linearGradient,
                gradientB: linearGradient.enhanced(),
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: _RadialGradientComparison(
                gradientA: radialGradient,
                gradientB: radialGradient.enhanced(),
              ),
            ),
            const SizedBox(height: 16),
            _SweepGradientComparison(
              gradientA: sweepGradient,
              gradientB: sweepGradient.enhanced(),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _LinearGradientComparison extends StatelessWidget {
  const _LinearGradientComparison({
    required this.gradientA,
    required this.gradientB,
  });

  final Gradient gradientA;
  final Gradient gradientB;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 200,
      height: 200,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: gradientA,
              ),
              child: const SizedBox(
                width: double.infinity,
              ),
            ),
          ),
          Expanded(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: gradientB,
              ),
              child: const SizedBox(
                width: double.infinity,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RadialGradientComparison extends StatelessWidget {
  const _RadialGradientComparison({
    required this.gradientA,
    required this.gradientB,
  });

  final RadialGradient gradientA;
  final RadialGradient gradientB;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const SizedBox(
          width: 200,
          height: 200,
        ),
        Positioned.fill(
          child: Align(
            alignment: Alignment.centerLeft,
            child: ClipRect(
              child: SizedBox(
                width: 100,
                height: 200,
                child: OverflowBox(
                  alignment: Alignment.centerLeft,
                  maxWidth: double.infinity,
                  child: SizedBox(
                    width: 200,
                    height: 200,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: gradientA,
                      ),
                      child: const SizedBox(
                        width: 200,
                        height: 200,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        Positioned.fill(
          child: Align(
            alignment: Alignment.centerRight,
            child: ClipRect(
              child: SizedBox(
                width: 100,
                height: 200,
                child: OverflowBox(
                  alignment: Alignment.centerRight,
                  maxWidth: double.infinity,
                  child: SizedBox(
                    width: 200,
                    height: 200,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: gradientB,
                      ),
                      child: const SizedBox(
                        width: 200,
                        height: 200,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _SweepGradientComparison extends StatelessWidget {
  const _SweepGradientComparison({
    required this.gradientA,
    required this.gradientB,
  });

  final Gradient gradientA;
  final Gradient gradientB;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        DecoratedBox(
          decoration: BoxDecoration(gradient: gradientA),
          child: const SizedBox(
            width: 200,
            height: 200,
          ),
        ),
        DecoratedBox(
          decoration: BoxDecoration(gradient: gradientB),
          child: const SizedBox(
            width: 200,
            height: 200,
          ),
        ),
      ],
    );
  }
}
