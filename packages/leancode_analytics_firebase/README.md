# leancode_analytics_firebase

Firebase Analytics implementation for LeanCode analytics.

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
