# login_client_flutter

[![login_client_flutter pub.dev badge][pub-badge]][pub-badge-link]
[![login_client_flutter continuous integration badge][build-badge]][build-badge-link]

[flutter_secure_storage] implementation of a `CredentialsStorage` for the [login_client] package.

## Usage

```dart
// Default usage
final loginClient = LoginClient(
  credentialsStorage: const FlutterSecureCredentialsStorage(),
  // ...
);
```

### Custom Configuration

You can provide a custom `FlutterSecureStorage` instance to configure platform-specific options:

```dart
final loginClient = LoginClient(
  credentialsStorage: const FlutterSecureCredentialsStorage(
    storage: FlutterSecureStorage(
      aOptions: AndroidOptions(
        encryptedSharedPreferences: true,
      ),
      iOptions: IOSOptions(
        accessibility: KeychainAccessibility.first_unlock_this_device,
      ),
    ),
  ),
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

[pub-badge]: https://img.shields.io/pub/v/login_client_flutter
[pub-badge-link]: https://pub.dev/packages/login_client_flutter
[build-badge]: https://img.shields.io/github/actions/workflow/status/leancodepl/flutter_corelibrary/login_client_flutter-test.yml?branch=master
[build-badge-link]: https://github.com/leancodepl/flutter_corelibrary/actions/workflows/login_client_flutter-test.yml
[flutter_secure_storage]: https://github.com/mogol/flutter_secure_storage
[login_client]: https://github.com/leancodepl/flutter_corelibrary/tree/master/packages/login_client
