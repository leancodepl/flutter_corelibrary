<a href="https://leancode.co/?utm_source=github.com&utm_medium=referral&utm_campaign=leancode-analytics-posthog" align="center">
  <img alt="leancode_analytics_posthog" src="https://github.com/user-attachments/assets/d5d0e0d8-c909-4b2f-b202-9c18a672ff47" />
</a>

# leancode_analytics_posthog

PostHog Analytics implementation for LeanCode analytics.
Uses [`leancode_analytics_base`](https://pub.dev/packages/leancode_analytics_base) package for core abstractions.

## Features

- PostHog Analytics integration
- Automatic screen view tracking via PosthogObserver (from posthog_flutter)
- Support for custom analytics events

## Usage

```dart
import 'package:leancode_analytics_posthog/leancode_analytics_posthog.dart';

// initialize PostHog with reexported Posthog class from posthog_flutter
await Posthog().setup(/* ... */);

// create instance of PostHogLeanAnalytics
final analytics = PostHogLeanAnalytics();

// Register custom events
analytics.register(TapAnalyticsEvent(key: 'button', label: 'Submit'));

// Add observers to your MaterialApp or router
MaterialApp(
  navigatorObservers: analytics.navigatorObservers,
  // ...
);
```

## Screen View Tracking

PostHog automatically tracks screen views using the `PosthogObserver` from the `posthog_flutter` package. The observer is reexported from this package for convenience.

