import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:leancode_analytics/leancode_analytics.dart';

/// Firebase implementation of LeanAnalytics
class FirebaseLeanAnalytics implements LeanAnalytics {
  /// Instance of [FirebaseAnalytics]
  final FirebaseAnalytics instance = FirebaseAnalytics.instance;

  @override
  Future<void> register(AnalyticsEvent event) async {
    if (event is ScreenViewAnalyticsEvent) {
      // Don't use firebase logScreenView method
      // because there you can't pass additional params
      await instance.logEvent(
        name: 'screen_view',
        parameters: event.params,
      );

      /// sets context for other events
      await instance.setCurrentScreen(
        screenName: event.name,
      );
    } else {
      await instance.logEvent(
        name: event.name,
        parameters: event.params,
      );
    }
  }
}
