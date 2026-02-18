<a href="https://leancode.co/?utm_source=github.com&utm_medium=referral&utm_campaign=leancode-analytics-posthog" align="center">
  <img alt="leancode_analytics_posthog" src="https://raw.githubusercontent.com/leancodepl/flutter_corelibrary/refs/heads/master/packages/leancode_analytics_posthog/docs/imgs/banner.png" />
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

---

## 🛠️ Maintained by LeanCode

<div align="center">
  <a href="https://leancode.co/?utm_source=github.com&utm_medium=referral&utm_campaign=leancode-analytics-posthog">
    <img src="https://leancodepublic.blob.core.windows.net/public/wide.png" alt="LeanCode Logo" height="100" />
  </a>
</div>

This package is built with 💙 by **[LeanCode](https://leancode.co?utm_source=github.com&utm_medium=referral&utm_campaign=leancode-analytics-posthog)**.
We are **top-tier experts** focused on Flutter Enterprise solutions.

### Why LeanCode?

- **Creators of [Patrol](https://patrol.leancode.co/?utm_source=github.com&utm_medium=referral&utm_campaign=leancode-analytics-posthog)** – the next-gen testing framework for Flutter.

- **Production-Ready** – We use this package in apps with millions of users.
- **Full-Cycle Product Development** – We take your product from scratch to long-term maintenance.

<div align="center">
  <br />

  **Need help with your Flutter project?**

  [**👉 Hire our team**](https://leancode.co/get-estimate?utm_source=github.com&utm_medium=referral&utm_campaign=leancode-analytics-posthog)
  &nbsp;&nbsp;•&nbsp;&nbsp;
  [Check our other packages](https://pub.dev/packages?q=publisher%3Aleancode.co&sort=downloads)

</div>