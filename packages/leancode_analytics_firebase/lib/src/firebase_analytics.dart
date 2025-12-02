import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/widgets.dart';
import 'package:leancode_analytics_base/leancode_analytics_base.dart';

import 'firebase_analytics_observer.dart';

class FirebaseLeanAnalytics implements LeanAnalytics {
  static final FirebaseAnalytics _instance = FirebaseAnalytics.instance;

  @override
  Future<void> register(AnalyticsEvent event) async {
    await _instance.logEvent(
      name: event.name,
      parameters: event.params,
    );
  }

  @override
  List<NavigatorObserver> get navigatorObservers =>
      [FirebaseAnalyticsNavigationObserver()];
}
