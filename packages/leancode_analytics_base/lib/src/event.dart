class AnalyticsEvent {
  const AnalyticsEvent({
    required this.name,
    this.params = const {},
  });

  final String name;
  final Map<String, Object> params;
}

class TapAnalyticsEvent extends AnalyticsEvent {
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

class LoginAnalyticsEvent extends AnalyticsEvent {
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
