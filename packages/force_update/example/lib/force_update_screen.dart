import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ForceUpdateScreen extends StatelessWidget {
  const ForceUpdateScreen({
    super.key,
    this.icon,
  });

  final Widget? icon;

  static const _androidBundleId = 'your_bundle_id';
  static const _appleAppId = 'your_app_id';

  Future<void> _goToStore() {
    final url = switch (defaultTargetPlatform) {
      TargetPlatform.android =>
        'https://play.google.com/store/apps/details?id=$_androidBundleId',
      TargetPlatform.iOS => 'https://apps.apple.com/pl/app/id$_appleAppId',
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
                    const Text('Update required'),
                    const SizedBox(height: 8),
                    const Text(
                      'To continue using the app, you have to update it',
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton(
                      onPressed: _goToStore,
                      child: const Text('Update'),
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
