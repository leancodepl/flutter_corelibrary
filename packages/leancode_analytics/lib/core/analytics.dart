import 'event.dart';

abstract interface class LeanAnalytics {
  void register(AnalyticsEvent event);

  // TODO: set default user params
  // set user data
  // void setDefaultParams(Object obj);
}
