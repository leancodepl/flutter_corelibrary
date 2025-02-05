part of 'force_update_guard.dart';

class ForceUpdateController {
  ForceUpdateController({
    required this.androidBundleId,
    required this.appleAppId,
  });

  final String androidBundleId;
  final String appleAppId;

  final _suggest = ValueNotifier(false);

  void hideSuggestDialog() {
    _suggest.value = false;
  }

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
