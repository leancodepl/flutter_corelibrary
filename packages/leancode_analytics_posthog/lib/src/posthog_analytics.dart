import 'package:flutter/widgets.dart';
import 'package:leancode_analytics_base/leancode_analytics_base.dart';
import 'package:posthog_flutter/posthog_flutter.dart';

class PostHogLeanAnalytics implements LeanAnalytics {
  @override
  Future<void> register(AnalyticsEvent event) async {
    await Posthog().capture(
      eventName: event.name,
      properties: event.params,
    );
  }

  @override
  List<NavigatorObserver> get navigatorObservers => [PosthogObserver()];
}
