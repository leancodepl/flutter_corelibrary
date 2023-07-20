# force_update

This is an internal Leancode package for quickly implementing Force Update. To use it, just wrap your `MaterialApp` in a `ForceUpdateGuard`
widget and pass an instance to CQRS.

# Behavior

On every app launch, a request will be made to fetch the minimum required version of the app. To avoid
affecting UX, the app will not wait for the request to complete. Instead, the result will be stored in prefs and used on next app launch. 
If the app notices on startup that the force updated is required, a force update screen will be shown. If the update is suggested (but not required), a dialog will be shown.
To keep the minimum required version up to date, requests are made every 5 minutes when the app is running.

# Usage

To use the package, wrap your `MaterialApp` with `ForceUpdateGuard` widget. You need to provide a `cqrs` instance, `suggestUpdateDialog` and `forceUpdateScreen` widgets and a `dialogContextKey` - this is a key used by the package to obtain a `BuildContext` when showing `suggestUpdateDialog`.

For a complete working sample, see [example](example).

# Configuration

Android has an API for performing updates within the app, without necessity of opening Play Store. To use the API, set `useAndroidSystemUI` to true in in the constructor of `ForceUpdateGuard`.