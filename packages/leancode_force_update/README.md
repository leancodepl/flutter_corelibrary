<a href="https://leancode.co/?utm_source=github.com&utm_medium=referral&utm_campaign=leancode-force-update" align="center">
  <img alt="leancode_force_update" src="https://raw.githubusercontent.com/leancodepl/flutter_corelibrary/refs/heads/master/packages/leancode_force_update/docs/imgs/banner.png" />
</a>

# leancode_force_update

This is an internal LeanCode package for quickly implementing Force Update. To use it, just wrap your `MaterialApp` in a `ForceUpdateGuard` widget and pass an instance of CQRS.

## Behavior

On every app launch, a request will be made to fetch the minimum required version of the app. Then the package can behave in two different ways depending on settings:

1. the result will be applied immediately after the response is obtained – if necessary, the package will display either force update screen or a dialog suggesting to update the app (default)
2. the result will be stored and applied on the subsequent app launch – this can be used if you do not want to interrupt the user after they have launched the app (for instance, they could have launched it without internet connection and then turn it on at some point) and would rather only show a force update screen or a dialog on app launch

While the first behavior is the default one, the second can be achieved by setting `showForceUpdateScreenImmediately` or `showSuggestUpdateDialogImmediately` to false in `ForceUpdateGuard`.

Regardless of those settings, to keep the minimum required version up to date, requests are also made every 5 minutes while the app is running.

## Usage

To use the package, wrap your `MaterialApp` with `ForceUpdateGuard` widget. You need to provide a `Cqrs` instance, `suggestUpdateDialog` and `forceUpdateScreen` widgets and a `ForceUpdateController` instance.

For a complete working sample, see [example](example).

## Configuration

Android has an API for performing updates within the app, without necessity of opening Play Store. To use the API, set `useAndroidSystemUI` to true in in the constructor of `ForceUpdateGuard`.

---

## 🛠️ Maintained by LeanCode

<div align="center">
  <a href="https://leancode.co/?utm_source=github.com&utm_medium=referral&utm_campaign=leancode-force-update">
    <img src="https://leancodepublic.blob.core.windows.net/public/wide.png" alt="LeanCode Logo" height="100" />
  </a>
</div>

This package is built with 💙 by **[LeanCode](https://leancode.co?utm_source=github.com&utm_medium=referral&utm_campaign=leancode-force-update)**.
We are **top-tier experts** focused on Flutter Enterprise solutions.

### Why LeanCode?

- **Creators of [Patrol](https://patrol.leancode.co/?utm_source=github.com&utm_medium=referral&utm_campaign=leancode-force-update)** – the next-gen testing framework for Flutter.

- **Production-Ready** – We use this package in apps with millions of users.
- **Full-Cycle Product Development** – We take your product from scratch to long-term maintenance.

<div align="center">
  <br />

  **Need help with your Flutter project?**

  [**👉 Hire our team**](https://leancode.co/get-estimate?utm_source=github.com&utm_medium=referral&utm_campaign=leancode-force-update)
  &nbsp;&nbsp;•&nbsp;&nbsp;
  [Check our other packages](https://pub.dev/packages?q=publisher%3Aleancode.co&sort=downloads)

</div>