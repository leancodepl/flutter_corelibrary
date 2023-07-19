import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';

class ForceUpdate {
  const ForceUpdate({
    required this.androidBundleId,
    required this.appleAppId,
  });

  final String androidBundleId;
  final String appleAppId;

  Future<bool> openStore() {
    final url = switch (defaultTargetPlatform) {
      TargetPlatform.android =>
        'https://play.google.com/store/apps/details?id=$androidBundleId',
      TargetPlatform.iOS => 'https://apps.apple.com/pl/app/id$appleAppId',
      _ => throw StateError('Force update only works for Android & iOS'),
    };

    return launchUrl(Uri.parse(url));
  }
}
