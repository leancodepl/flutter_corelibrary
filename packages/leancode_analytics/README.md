# leancode_analytics

This is LeanCode package to add base analytics in flutter app. 

## Features

- Custom NavigatorObserver for registering events on `Route` changes
- TapAnalyticsEvent 

## Getting started

Add leancode_analytics package to your app, by running this command:

```bash
flutter pub add leancode_analytics
```

Create Google analytics project and add Firebase to your app based on this documentation:
https://firebase.google.com/docs/analytics/get-started?platform=flutter

## Usage

Create instance of `FirebaseLeanAnalytics` and add it to your DI.

Add `LeanAnalyticsNavigationObserver` to your Navigation observers eg. for `GoRouter`:

```dart
GoRouter(
    ...

    observers: [LeanAnalyticsNavigationObserver(context.read<LeanAnalytics>())],

    ...
  )
```

Implement `LeanAnalyticsRoute` in your custom `Route` and use it for all screens that should be registered.

### Tap event

Register tap event in all your tappable widgets:

```dart
context.read<LeanAnalytics>().register(
    TapAnalyticsEvent(
        key: key,
        label: label,
    ),
);
```

### Login event

Send login event:

```dart
context.read<LeanAnalytics>().register(
    LoginAnalyticsEvent(userId: userId),
);
```
