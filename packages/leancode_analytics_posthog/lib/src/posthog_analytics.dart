import 'package:flutter/widgets.dart';
import 'package:leancode_analytics_base/leancode_analytics_base.dart';
import 'package:leancode_analytics_posthog/src/posthog_analytics_observer.dart';
import 'package:posthog_flutter/posthog_flutter.dart';

/// PostHog implementation of [LeanAnalytics].
///
/// Uses PostHog to track events and screen views.
/// Requires PostHog to be configured before use.
class PostHogLeanAnalytics implements LeanAnalytics {
  @override
  Future<void> register(AnalyticsEvent event) async {
    await Posthog().capture(
      eventName: event.name,
      properties: event.params,
    );
  }

  @override
  List<NavigatorObserver> get navigatorObservers => [
        LeanAnalyticsPostHogObserver(),
      ];
}
