import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:leancode_analytics/leancode_analytics.dart';

/// Firebase implementation of LeanAnalytics
class FirebaseLeanAnalytics implements LeanAnalytics {
  /// Instance of [FirebaseAnalytics]
  static final FirebaseAnalytics _instance = FirebaseAnalytics.instance;

  @override
  Future<void> register(AnalyticsEvent event) async {
    if (event is ScreenViewAnalyticsEvent) {
      // Don't use firebase logScreenView method
      // because there you can't pass additional params
      await _instance.logEvent(
        name: 'screen_view',
        parameters: event.params,
      );

      /// sets context for other events
      await _instance.setCurrentScreen(
        screenName: event.name,
      );
    } else {
      await _instance.logEvent(
        name: event.name,
        parameters: event.params,
      );
    }
  }
}
