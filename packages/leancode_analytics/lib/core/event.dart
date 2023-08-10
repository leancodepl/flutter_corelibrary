import 'package:flutter/foundation.dart';

/// Basic [AnalyticsEvent] - you can send directly this event with
/// predefined parameters or extend this class to create more specific events
class AnalyticsEvent {
  /// Creates [AnalyticsEvent]
  const AnalyticsEvent({
    required this.name,
    this.params = const {},
  });

  /// Name of the event
  final String name;

  /// Optional event parameters - empty Map by default
  final Map<String, Object> params;
}

/// Differentiates how new LeanAnalyticsRoute been passed
enum ScreenViewType {
  /// New Route was pushed
  push,

  /// Previous Route was poped,
  pop,

  /// App back from background
  restore;
}

/// [AnalyticsEvent] for push or pop Route. Distinguished because usually
/// with event send on change screen view also modify screen context for
/// other events
class ScreenViewAnalyticsEvent extends AnalyticsEvent {
  /// Create [ScreenViewAnalyticsEvent] with [pageName], [screenViewType]
  /// and optional [params]
  ScreenViewAnalyticsEvent({
    required String pageName,
    required ScreenViewType screenViewType,
    Map<String, Object> params = const {},
  })  : assert(
          !params.keys.contains('page_name'),
          "Don't pass 'page_name' key in params. It will be overridden",
        ),
        assert(
          !params.keys.contains('action_type'),
          "Don't pass 'action_type' key in params. It will be overridden",
        ),
        super(
          name: pageName,
          params: {
            ...params,
            'page_name': pageName,
            'action_type': screenViewType.name,
          },
        );
}

/// [AnalyticsEvent] for tap some clickable element
class TapAnalyticsEvent extends AnalyticsEvent {
  /// Create [TapAnalyticsEvent] with [key], tapped element [label]
  /// and optional [params]
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

/// [AnalyticsEvent] for registering login event. Pass user_id as param
class LoginAnalyticsEvent extends AnalyticsEvent {
  /// Create [LoginAnalyticsEvent] with [userId] and optional [params]
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
