# force_update

This is an internal Leancode package for quickly implementing Force Update. To use it, just wrap your `MaterialApp` in a `ForceUpdateGuard`
widget and pass an instance to CQRS.

# behavior

On every app launch, a request will be made to fetch the minimum required version of the app. To avoid
affecting UX, the app will not wait for the request to complete. Instead, the result will be stored in prefs and used on next app launch. 
If the app notices on startup that the minimum version stored in prefs is higher than the current one, a force update screen will be shown.
To keep the minimum required version up to date, requests are made every 5 minutes when the app is running. 