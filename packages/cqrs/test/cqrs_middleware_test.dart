import 'package:cqrs/cqrs.dart';
import 'package:cqrs/src/cqrs_middleware.dart';
import 'package:test/test.dart';

void main() {
  final middleware = ExampleCqrsMiddleware();

  group('CqrsMiddleware', () {
    group('handleQueryResult', () {
      test('returns the same result by default', () async {
        const resultIn = QSuccess(true);
        final resultOut = await middleware.handleQueryResult(resultIn);
        expect(resultIn, resultOut);
      });
    });

    group('handleCommandResult', () {
      test('returns the same result by default', () async {
        const resultIn = CqrsCommandSuccess();
        final resultOut = await middleware.handleCommandResult(resultIn);
        expect(resultIn, resultOut);
      });
    });

    group('handleOperationResult', () {
      test('returns the same result by default', () async {
        const resultIn = CqrsOperationSuccess(true);
        final resultOut = await middleware.handleOperationResult(resultIn);
        expect(resultIn, resultOut);
      });
    });
  });
}

class ExampleCqrsMiddleware extends CqrsMiddleware {}
