# login_client_flutter

[![login_client_flutter pub.dev badge][login_client_flutter-pub-badge]][login_client_flutter-pub-badge-link]
[![login_client_flutter continuous integration badge][login_client_flutter-build-badge]][login_client_flutter-build-badge-link]

[flutter_secure_storage] implementation of a `CredentialsStorage` for the [login_client] package.

## Usage

```dart
final loginClient = LoginClient(
  credentialsStorage: const FlutterSecureCredentialsStorage(),
  // ...
);
```

## Android `javax.crypto.BadPaddingException`

Exclude Flutter Secure Storage from Android full backup.

```xml
<!-- AndroidManifest.xml -->

    <application
        ...
        android:fullBackupContent="@xml/backup_rules">
```

```xml
<!-- res/xml/backup_rules.xml -->

<?xml version="1.0" encoding="utf-8"?>
<full-backup-content>
    <exclude domain="sharedpref" path="FlutterSecureStorage" />
</full-backup-content>
```

[login_client_flutter-pub-badge]: https://img.shields.io/pub/v/login_client_flutter
[login_client_flutter-pub-badge-link]: https://pub.dev/packages/login_client_flutter
[login_client_flutter-build-badge]: https://img.shields.io/github/workflow/status/leancodepl/flutter_corelibrary/login_client_flutter%20test
[login_client_flutter-build-badge-link]: https://github.com/leancodepl/flutter_corelibrary/actions?query=workflow%3A%22login_client_flutter+test%22
[flutter_secure_storage]: https://github.com/mogol/flutter_secure_storage
[login_client]: https://github.com/leancodepl/flutter_corelibrary/tree/master/packages/login_client
