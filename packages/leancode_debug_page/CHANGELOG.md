## 3.0.0

- **Breaking:** Fix navigation inside the debug page.
  - `DebugPageController` now requires a navigator key.
  - `DebugPageController`'s `navigatorObserver` now needs to be passed to the app widget.

## 2.2.0

- Revamped log details: organized UI with error objects, sequence numbers, zone info, and full scrollable stack traces.
- Sharing now includes complete log context, not just the message.
- Updated example app with comprehensive test logs and FlutterError simulations.

## 2.1.3

- Fix a bug causing an exception on web (#466)

## 2.1.2

- Fix logging response bodies

## 2.1.1

- Downgrade `sensors_plus` dependency to `^6.0.0`
- Downgrade `share_plus` dependency to `^10.0.0`

## 2.1.0

- Bump minimum Flutter version to 3.27.0
- Bump minimum Dart version to 3.6.0
- Bump `sensors_plus` dependency to `^6.1.1`
- Bump `share_plus` dependency to `^10.1.4`
- Bump `leancode_lint` dependency to `^15.0.0`

## 2.0.0

- Bump `rxdart` dependency to `^0.28.0`
- **Breaking:** Bump minimum Dart version to 3.5.0
- Bump `custom_lint` dependency to `^0.7.0`
- Bump `leancode_lint` dependency to `^14.0.0`

## 1.0.2

- Vendor shake package to avoid using obsolete version of sensors_plus

## 1.0.1

- Fix screenshots in README.md

## 1.0.0

- Initial release
