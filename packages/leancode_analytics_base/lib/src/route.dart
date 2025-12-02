/// Interface for routes that should be tracked by analytics.
///
/// Implement this interface on your route classes to enable automatic
/// screen view tracking.
abstract interface class LeanAnalyticsRoute {
  /// Unique identifier for this screen/route used in analytics.
  String get id;

  /// Optional parameters to include with screen view events.
  Map<String, dynamic>? get analyticsParams;
}
