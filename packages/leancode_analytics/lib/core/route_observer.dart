import 'package:flutter/material.dart';
import 'package:leancode_analytics/leancode_analytics.dart';

abstract class LeanRoute extends MaterialPageRoute<void> {
  LeanRoute(
    this.name, {
    required super.builder,
    required super.settings,
  });

  final String name;
}

class LeanAnalyticsNavigationObserver extends NavigatorObserver {
  LeanAnalyticsNavigationObserver(this.analytics);

  final LeanAnalytics analytics;

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    if (route case LeanRoute()) {
      analytics.register(
        ScreenViewAnalyticsEvent(
          pageName: route.name,
          screenViewType: ScreenViewType.push,
        ),
      );
    }
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    if (previousRoute case LeanRoute()) {
      analytics.register(
        ScreenViewAnalyticsEvent(
          pageName: previousRoute.name,
          screenViewType: ScreenViewType.pop,
        ),
      );
    }
  }

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) {
    if (previousRoute case LeanRoute()) {
      analytics.register(
        ScreenViewAnalyticsEvent(
          pageName: previousRoute.name,
          screenViewType: ScreenViewType.pop,
        ),
      );
    }
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    if (newRoute case LeanRoute()) {
      analytics.register(
        ScreenViewAnalyticsEvent(
          pageName: newRoute.name,
          screenViewType: ScreenViewType.push,
        ),
      );
    }
  }
}
