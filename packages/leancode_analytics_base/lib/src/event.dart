/// Base class for all analytics events.
///
/// Create custom events by extending this class or use built-in events like
/// [TapAnalyticsEvent] and [LoginAnalyticsEvent].
class AnalyticsEvent {
  /// Creates an analytics event with a [name] and optional [params].
  const AnalyticsEvent({
    required this.name,
    this.params = const {},
  });

  /// The name of the event used for tracking.
  final String name;

  /// Additional parameters associated with this event.
  final Map<String, Object> params;
}

/// An analytics event for tracking user taps/clicks.
///
/// Automatically includes `key` and optionally `label` in the event params.
class TapAnalyticsEvent extends AnalyticsEvent {
  /// Creates a tap event with a unique [key] identifier and optional [label].
  ///
  /// The [key] should uniquely identify the tapped element.
  /// The [label] can provide additional context (e.g., button text).
  TapAnalyticsEvent({
    required String key,
    required String? label,
    Map<String, Object> params = const {},
  })  : assert(
          !params.keys.contains('key'),
          "Don't pass 'key' key in params. It will be overridden",
        ),
        assert(
          !params.keys.contains('label'),
          "Don't pass 'label' key in params. It may be overridden",
        ),
        super(
          name: 'tap',
          params: {
            ...params,
            'key': key,
            if (label != null) 'label': label,
          },
        );
}

/// An analytics event for tracking user login.
///
/// Automatically includes `user_id` in the event params.
class LoginAnalyticsEvent extends AnalyticsEvent {
  /// Creates a login event with the [userId] of the logged-in user.
  LoginAnalyticsEvent({
    required String userId,
    Map<String, Object> params = const {},
  })  : assert(
          !params.keys.contains('user_id'),
          "Don't pass 'user_id' key in params. It will be overridden",
        ),
        super(
          name: 'login',
          params: {
            ...params,
            'user_id': userId,
          },
        );
}
