import 'package:flutter/widgets.dart';

import 'event.dart';

abstract interface class LeanAnalytics {
  void register(AnalyticsEvent event);

  List<NavigatorObserver> get navigatorObservers;
}
