import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ForceUpdateScreen extends StatelessWidget {
  const ForceUpdateScreen({
    super.key,
    this.icon,
  });

  final Widget? icon;

  Future<void> _goToStore() {
    final url = switch (defaultTargetPlatform) {
      TargetPlatform.android =>
        'https://play.google.com/store/apps/details?id={{bundle_id}}',
      TargetPlatform.iOS => 'https://apps.apple.com/pl/app/id{{apple_app_id}}',
      _ => throw StateError('Force update only works for Android & iOS'),
    };

    return launchUrl(Uri.parse(url));
  }

  @override
  Widget build(BuildContext context) {
    final icon = this.icon;

    return MaterialApp(
      home: Scaffold(
        body: SafeArea(
          child: DefaultTextStyle(
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.black,
            ),
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (icon != null) ...[
                      icon,
                      const SizedBox(height: 24),
                    ],
                    const Text('Aktualizuj aplikację'),
                    const SizedBox(height: 8),
                    const Text(
                      'Aby móc korzystac z aplikacji, wymagana jest aktualizacja do najnowszej wersji',
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton(
                      onPressed: _goToStore,
                      child: const Text('Aktualizuj'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
