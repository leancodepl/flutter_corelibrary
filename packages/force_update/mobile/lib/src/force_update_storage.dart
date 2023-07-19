import 'dart:convert';

import 'package:force_update/data/contracts/contracts.dart';
import 'package:force_update/src/app_version.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ForceUpdateResult {
  const ForceUpdateResult({
    required this.versionAtTimeOfRequest,
    required this.result,
  });

  final AppVersion versionAtTimeOfRequest;
  final VersionSupportResultDTO result;

  ForceUpdateResult.fromJson(Map<String, dynamic> json)
      : versionAtTimeOfRequest = AppVersion(
          version: json['versionAtTimeOfRequest'],
        ),
        result = VersionSupportResultDTO.values[json['result']];

  Map<String, dynamic> toJson() => {
        'versionAtTimeOfRequest': versionAtTimeOfRequest.version,
        'result': result.index,
      };
}

class ForceUpdateStorage {
  ForceUpdateStorage() : _getPrefs = SharedPreferences.getInstance();

  final Future<SharedPreferences> _getPrefs;

  static const _mostRecentResultKey = 'most_recent_result';

  Future<ForceUpdateResult?> readMostRecentResult() async {
    final prefs = await _getPrefs;

    final mostRecentResult = prefs.getString(_mostRecentResultKey);
    if (mostRecentResult == null) {
      return null;
    }

    return ForceUpdateResult.fromJson(jsonDecode(mostRecentResult));
  }

  Future<void> writeResult(ForceUpdateResult result) async {
    final prefs = await _getPrefs;
    prefs.setString(_mostRecentResultKey, jsonEncode(result.toJson()));
  }
}
