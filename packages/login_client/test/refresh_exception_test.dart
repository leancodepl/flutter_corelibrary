import 'package:login_client/src/refresh_exception.dart';
import 'package:test/test.dart';

void main() {
  group('RefreshException', () {
    test('has correct message property', () {
      const exception = RefreshException('This is test');

      expect(exception.message, 'This is test');
    });

    test('has correct toString value', () {
      const exception = RefreshException('Hey!');

      expect(exception.toString(), 'RefreshException: Hey!');
    });
  });
}
