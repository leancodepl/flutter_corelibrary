<a href="https://leancode.co/?utm_source=github.com&utm_medium=referral&utm_campaign=leancode-analytics-firebase" align="center">
  <img alt="leancode_analytics_firebase" src="https://raw.githubusercontent.com/leancodepl/flutter_corelibrary/refs/heads/master/packages/leancode_analytics_firebase/docs/imgs/banner.png" />
</a>

# leancode_analytics_firebase

Firebase Analytics implementation for LeanCode analytics.
Uses [`leancode_analytics_base`](https://pub.dev/packages/leancode_analytics_base) package for core abstractions.

## Features

- Firebase Analytics integration
- Automatic screen view tracking via NavigatorObserver
- Support for custom analytics events

## Usage

```dart
import 'package:leancode_analytics_firebase/leancode_analytics_firebase.dart';

// initialize Firebase with reexported Firebase class from firebase_core
await Firebase.initializeApp(options: firebaseOptions);

// create instance of FirebaseLeanAnalytics
final analytics = FirebaseLeanAnalytics();

// Register custom events
analytics.register(TapAnalyticsEvent(key: 'button', label: 'Submit'));

// Add observers to your MaterialApp or router
MaterialApp(
  navigatorObservers: analytics.navigatorObservers,
  // ...
);
```

---

## 🛠️ Maintained by LeanCode

<div align="center">
  <a href="https://leancode.co/?utm_source=github.com&utm_medium=referral&utm_campaign=leancode-analytics-firebase">
    <img src="https://leancodepublic.blob.core.windows.net/public/wide.png" alt="LeanCode Logo" height="100" />
  </a>
</div>

This package is built with 💙 by **[LeanCode](https://leancode.co?utm_source=github.com&utm_medium=referral&utm_campaign=leancode-analytics-firebase)**.
We are **top-tier experts** focused on Flutter Enterprise solutions.

### Why LeanCode?

- **Creators of [Patrol](https://patrol.leancode.co/?utm_source=github.com&utm_medium=referral&utm_campaign=leancode-analytics-firebase)** – the next-gen testing framework for Flutter.

- **Production-Ready** – We use this package in apps with millions of users.
- **Full-Cycle Product Development** – We take your product from scratch to long-term maintenance.

<div align="center">
  <br />

  **Need help with your Flutter project?**

  [**👉 Hire our team**](https://leancode.co/get-estimate?utm_source=github.com&utm_medium=referral&utm_campaign=leancode-analytics-firebase)
  &nbsp;&nbsp;•&nbsp;&nbsp;
  [Check our other packages](https://pub.dev/packages?q=publisher%3Aleancode.co&sort=downloads)

</div>