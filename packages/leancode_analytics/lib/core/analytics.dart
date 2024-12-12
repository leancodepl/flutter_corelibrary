import 'event.dart';

/// Main abstraction for LeanCode Analytics
abstract interface class LeanAnalytics {
  /// Register [AnalyticsEvent]
  void register(AnalyticsEvent event);

  // TODO: set default user params
  // set user data
  // void setDefaultParams(Object obj);
}
