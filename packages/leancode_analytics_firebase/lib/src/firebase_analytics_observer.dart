import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:leancode_analytics_base/leancode_analytics_base.dart';

class FirebaseAnalyticsNavigationObserver extends NavigatorObserver {
  static final FirebaseAnalytics _instance = FirebaseAnalytics.instance;

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    if (route case final LeanAnalyticsRoute route) {
      _instance.logScreenView(
        screenName: route.id,
        parameters: route.analyticsParams,
      );
    }
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    if (previousRoute case final LeanAnalyticsRoute previousRoute?) {
      _instance.logScreenView(
        screenName: previousRoute.id,
        parameters: previousRoute.analyticsParams,
      );
    }
  }

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) {
    if (previousRoute case final LeanAnalyticsRoute previousRoute?) {
      _instance.logScreenView(
        screenName: previousRoute.id,
        parameters: previousRoute.analyticsParams,
      );
    }
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    if (newRoute case final LeanAnalyticsRoute newRoute?) {
      _instance.logScreenView(
        screenName: newRoute.id,
        parameters: newRoute.analyticsParams,
      );
    }
  }
}
