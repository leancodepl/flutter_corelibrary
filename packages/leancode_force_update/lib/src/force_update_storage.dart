import 'dart:convert';

import 'package:leancode_force_update/data/contracts/contracts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:version/version.dart';

class ForceUpdateResult {
  const ForceUpdateResult({
    required this.versionAtTimeOfRequest,
    required this.conclusion,
  });

  ForceUpdateResult.fromJson(Map<String, dynamic> json)
      : versionAtTimeOfRequest =
            Version.parse(json['versionAtTimeOfRequest'] as String),
        conclusion = VersionSupportResultDTO.values[json['conclusion'] as int];

  final Version versionAtTimeOfRequest;
  final VersionSupportResultDTO conclusion;

  Map<String, dynamic> toJson() => {
        'versionAtTimeOfRequest': versionAtTimeOfRequest.toString(),
        'conclusion': conclusion.index,
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

    return ForceUpdateResult.fromJson(
      jsonDecode(mostRecentResult) as Map<String, dynamic>,
    );
  }

  Future<void> writeResult(ForceUpdateResult result) async {
    final prefs = await _getPrefs;
    await prefs.setString(_mostRecentResultKey, jsonEncode(result.toJson()));
  }
}
