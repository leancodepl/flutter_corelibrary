import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:lean_analytics/core/core.dart';

class FirebaseLeanAnalytics extends LeanAnalytics {
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
