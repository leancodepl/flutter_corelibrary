import 'package:flutter/widgets.dart';
import 'package:leancode_analytics_base/leancode_analytics_base.dart';
import 'package:posthog_flutter/posthog_flutter.dart';

/// PostHog observer that tracks screen views for routes implementing
/// [LeanAnalyticsRoute].
class LeanAnalyticsPostHogObserver extends PosthogObserver {
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    if (route is LeanAnalyticsRoute) {
      _sendLeanAnalyticsScreen(route as LeanAnalyticsRoute);
    }
    super.didPush(route, previousRoute);
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    if (newRoute is LeanAnalyticsRoute && newRoute != null) {
      _sendLeanAnalyticsScreen(newRoute as LeanAnalyticsRoute);
    }
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    if (previousRoute is LeanAnalyticsRoute && previousRoute != null) {
      _sendLeanAnalyticsScreen(previousRoute as LeanAnalyticsRoute);
    }
    super.didPop(route, previousRoute);
  }

  void _sendLeanAnalyticsScreen(LeanAnalyticsRoute route) {
    final params = route.analyticsParams;
    final properties = params?.map(
      (key, value) => MapEntry<String, Object>(key, value as Object),
    );
    Posthog().screen(
      screenName: route.id,
      properties: properties,
    );
  }
}
