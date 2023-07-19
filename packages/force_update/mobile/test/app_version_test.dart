import 'package:flutter_test/flutter_test.dart';
import 'package:force_update/src/app_version.dart';

void main() {
  group('AppVersion', () {
    test('Case 1', () {
      expect(
          const AppVersion(version: '0.9.0') <
              const AppVersion(version: '1.0.0'),
          true);
    });
    test('Case 2', () {
      expect(
          const AppVersion(version: '1.0.0') <
              const AppVersion(version: '1.0.0'),
          false);
    });
    test('Case 3', () {
      expect(
          const AppVersion(version: '1.0.0') <
              const AppVersion(version: '1.0.0.0.0.1'),
          true);
    });
    test('Case 4', () {
      expect(
          const AppVersion(version: '1.0.1') > const AppVersion(version: '1'),
          true);
    });
    test('Case 5', () {
      expect(
          const AppVersion(version: '0.861') >
              const AppVersion(version: '0.86.1'),
          true);
    });
  });
}
