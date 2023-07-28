import 'package:flutter/material.dart';
import 'package:leancode_analytics/leancode_analytics.dart';

/// Interface that should be impletemented by default app [Route]
abstract interface class LeanAnalyticsRoute {
  /// Required identifier to distinguish page Routes
  String get id;

  /// Optional [analyticsParams] to pass with [ScreenViewAnalyticsEvent]
  Map<String, dynamic>? get analyticsParams;
}

/// [NavigatorObserver] that register event when [LeanAnalyticsRoute] shows
/// on the screen
class LeanAnalyticsNavigationObserver extends NavigatorObserver {
  /// Creates a [LeanAnalyticsNavigationObserver] with [analytics]
  LeanAnalyticsNavigationObserver(this.analytics);

  /// Instance of [LeanAnalytics] to register events on [Route] changes
  final LeanAnalytics analytics;

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    if (route case LeanAnalyticsRoute _) {
      analytics.register(
        ScreenViewAnalyticsEvent(
          pageName: (route as LeanAnalyticsRoute).id,
          screenViewType: ScreenViewType.push,
        ),
      );
    }
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    if (previousRoute case final LeanAnalyticsRoute previousRoute?) {
      analytics.register(
        ScreenViewAnalyticsEvent(
          pageName: previousRoute.id,
          screenViewType: ScreenViewType.pop,
        ),
      );
    }
  }

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) {
    if (previousRoute case final LeanAnalyticsRoute previousRoute?) {
      analytics.register(
        ScreenViewAnalyticsEvent(
          pageName: previousRoute.id,
          screenViewType: ScreenViewType.pop,
        ),
      );
    }
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    if (newRoute case final LeanAnalyticsRoute newRoute?) {
      analytics.register(
        ScreenViewAnalyticsEvent(
          pageName: newRoute.id,
          screenViewType: ScreenViewType.push,
        ),
      );
    }
  }
}
