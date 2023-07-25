import 'package:flutter/foundation.dart';

class AnalyticsEvent {
  AnalyticsEvent({
    required this.name,
    this.params,
  });

  final Map<String, Object>? params;
  final String name;
}

enum ScreenViewType {
  push,
  pop,
  restore;
}

class ScreenViewAnalyticsEvent extends AnalyticsEvent {
  ScreenViewAnalyticsEvent({
    required String pageName,
    required ScreenViewType screenViewType,
    Map<String, Object>? params,
  }) : super(
          name: pageName,
          params: {
            if (params != null) ...params,
            'page_name': pageName,
            'action_type': screenViewType.name,
          },
        );
}

class TapAnalyticsEvent extends AnalyticsEvent {
  TapAnalyticsEvent({
    required ValueKey<String> key,
    required String? label,
    Map<String, Object>? params,
  }) : super(
          name: 'tap',
          params: {
            if (params != null) ...params,
            'key': key.value,
            if (label != null) 'label': label
          },
        );
}

class LoginAnalyticsEvent extends AnalyticsEvent {
  LoginAnalyticsEvent({required String userId, Map<String, Object>? params})
      : super(
          name: 'login',
          params: {
            if (params != null) ...params,
            'user_id': userId,
          },
        );
}
