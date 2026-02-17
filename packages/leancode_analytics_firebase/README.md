<a href="https://leancode.co/?utm_source=github.com&utm_medium=referral&utm_campaign=leancode-analytics-firebase" align="center">
  <img alt="leancode_analytics_firebase" src="https://github.com/user-attachments/assets/87f93726-fbdc-46b0-beac-e11a42b0b8a7" />
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
