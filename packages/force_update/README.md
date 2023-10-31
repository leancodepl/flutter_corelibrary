# force_update

This is an internal Leancode package for quickly implementing Force Update. To use it, just wrap your `MaterialApp` in a `ForceUpdateGuard`
widget and pass an instance of CQRS.

# Behaviour

On every app launch, a request will be made to fetch the minimum required version of the app. By default, the result will be applied immediately after the response is obtained - if necessary, the package will display either force update screen or a dialog suggesting to update the app. If you do not want to interrupt the user after they have launched the app (for instance, they could have launched it without internet connection and then turn it on at some point) and would rather only show a force update screen or a dialog on app launch, you can change the behaviour of the package to make it store the responses and apply them on subsequent app launches. This can be done by setting `showForceUpdateScreenImmediately` or `showSuggestUpdateDialogImmediately` to false in `ForceUpdateGuard`. Regardless of those settings, to keep the minimum required version up to date, requests are made every 5 minutes while the app is running.

# Usage

To use the package, wrap your `MaterialApp` with `ForceUpdateGuard` widget. You need to provide a `cqrs` instance, `suggestUpdateDialog` and `forceUpdateScreen` widgets and a `dialogContextKey` - this is a key used by the package to obtain a `BuildContext` when showing `suggestUpdateDialog`.

For a complete working sample, see [example](example).

# Configuration

Android has an API for performing updates within the app, without necessity of opening Play Store. To use the API, set `useAndroidSystemUI` to true in in the constructor of `ForceUpdateGuard`.