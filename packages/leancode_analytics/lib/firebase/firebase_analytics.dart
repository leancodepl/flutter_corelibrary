import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:leancode_analytics/leancode_analytics.dart';

/// Firebase implementation of LeanAnalytics
class FirebaseLeanAnalytics implements LeanAnalytics {
  /// Instance of [FirebaseAnalytics]
  static final FirebaseAnalytics _instance = FirebaseAnalytics.instance;

  @override
  Future<void> register(AnalyticsEvent event) async {
    if (event is ScreenViewAnalyticsEvent) {
      await _instance.logScreenView(
        screenName: event.name,
        parameters: event.params,
      );
    } else {
      await _instance.logEvent(
        name: event.name,
        parameters: event.params,
      );
    }
  }
}
