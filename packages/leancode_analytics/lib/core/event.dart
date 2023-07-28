import 'package:flutter/foundation.dart';

class AnalyticsEvent {
  AnalyticsEvent({
    required this.name,
    this.params = const {},
  });

  final Map<String, Object> params;
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
    Map<String, Object> params = const {},
  })  : assert(
          params.keys.contains('page_name'),
          "Don't pass 'page_name' key in params. It will be overridden",
        ),
        assert(
          params.keys.contains('action_type'),
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

class TapAnalyticsEvent extends AnalyticsEvent {
  TapAnalyticsEvent({
    required ValueKey<String> key,
    required String? label,
    Map<String, Object> params = const {},
  })  : assert(
          params.keys.contains('key'),
          "Don't pass 'key' key in params. It will be overridden",
        ),
        assert(
          params.keys.contains('label'),
          "Don't pass 'label' key in params. It may be overridden",
        ),
        super(
          name: 'tap',
          params: {
            ...params,
            'key': key.value,
            if (label != null) 'label': label
          },
        );
}

class LoginAnalyticsEvent extends AnalyticsEvent {
  LoginAnalyticsEvent({
    required String userId,
    Map<String, Object> params = const {},
  })  : assert(
          params.keys.contains('user_id'),
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
