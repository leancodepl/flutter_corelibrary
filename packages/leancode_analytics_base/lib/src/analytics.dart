import 'package:flutter/widgets.dart';

import 'event.dart';

/// Base interface for analytics implementations.
///
/// Provides a unified API for tracking analytics events and observing
/// navigation changes across different analytics providers.
abstract interface class LeanAnalytics {
  /// Registers an analytics event to be tracked.
  void register(AnalyticsEvent event);

  /// Returns a list of [NavigatorObserver]s for automatic screen tracking.
  List<NavigatorObserver> get navigatorObservers;
}
