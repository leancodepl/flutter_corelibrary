import 'package:force_update/src/app_version.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ForceUpdateStorage {
  ForceUpdateStorage() : _getPrefs = SharedPreferences.getInstance();

  final Future<SharedPreferences> _getPrefs;

  static const _key = 'minRequiredVersion';

  Future<AppVersion?> readMinRequiredVersion() async {
    final prefs = await _getPrefs;
    final versionString = prefs.getString(_key);
    if (versionString == null) {
      return null;
    }

    return AppVersion(version: versionString);
  }

  Future<void> writeMinRequiredVersion(AppVersion value) async {
    final prefs = await _getPrefs;
    prefs.setString(_key, value.version);
  }
}
