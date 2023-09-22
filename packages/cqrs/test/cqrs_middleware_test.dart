import 'package:cqrs/cqrs.dart';
import 'package:cqrs/src/cqrs_middleware.dart';
import 'package:test/test.dart';

void main() {
  final middleware = ExampleCqrsMiddleware();

  group('CqrsMiddleware', () {
    group('handleResult', () {
      test('returns the same result by default', () async {
        const resultIn = QuerySuccess(true);
        final resultOut = await middleware.handleResult(resultIn);
        expect(resultIn, resultOut);
      });
    });
  });
}

class ExampleCqrsMiddleware extends CqrsMiddleware {}
