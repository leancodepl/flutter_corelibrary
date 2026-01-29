import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:leancode_analytics_base/leancode_analytics_base.dart';

/// The type of navigation action that triggered a screen view.
enum ScreenViewType {
  /// A new route was pushed onto the navigator.
  push,

  /// A route was popped from the navigator.
  pop,
}

/// A [NavigatorObserver] that logs screen views to Firebase Analytics.
///
/// Automatically tracks screen views for routes implementing [LeanAnalyticsRoute].
class FirebaseAnalyticsNavigationObserver extends NavigatorObserver {
  static final FirebaseAnalytics _instance = FirebaseAnalytics.instance;

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    if (route case final LeanAnalyticsRoute route) {
      _instance.logScreenView(
        screenName: route.id,
        parameters: {
          'action_type': ScreenViewType.push.name,
        },
      );
    }
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    if (previousRoute case final LeanAnalyticsRoute previousRoute?) {
      _instance.logScreenView(
        screenName: previousRoute.id,
        parameters: {
          'action_type': ScreenViewType.pop.name,
        },
      );
    }
  }

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) {
    if (previousRoute case final LeanAnalyticsRoute previousRoute?) {
      _instance.logScreenView(
        screenName: previousRoute.id,
        parameters: {
          'action_type': ScreenViewType.pop.name,
        },
      );
    }
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    if (newRoute case final LeanAnalyticsRoute newRoute?) {
      _instance.logScreenView(
        screenName: newRoute.id,
        parameters: {
          'action_type': ScreenViewType.push.name,
        },
      );
    }
  }
}
