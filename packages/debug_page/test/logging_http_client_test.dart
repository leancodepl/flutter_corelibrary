import 'package:debug_page/debug_page.dart';
import 'package:debug_page/src/models/request_log_record.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart';
import 'package:mocktail/mocktail.dart';

import 'util/mock_http_client.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group(
    'LoggingHttpClient',
    () {
      final homeUrl = Uri.parse('https://leancode.co/');
      final request = Request('get', homeUrl);
      const stream = Stream<List<int>>.empty();
      const statusCode = 200;
      const contentLength = 123;
      const headers = <String, String>{};
      const isRedirect = false;
      const persistentConnection = true;
      const reasonPhrase = 'reasonPhrase';

      late MockHttpClient mockHttpClient;
      late LoggingHttpClient loggingHttpClient;

      setUpAll(() {
        registerFallbackValue(Request('get', Uri()));
      });

      setUp(() {
        mockHttpClient = MockHttpClient();
        loggingHttpClient = LoggingHttpClient(client: mockHttpClient);

        when<Future<StreamedResponse>>(() => mockHttpClient.send(any()))
            .thenAnswer(
          (invocation) async => StreamedResponse(
            stream,
            statusCode,
            contentLength: contentLength,
            request: request,
            reasonPhrase: reasonPhrase,
          ),
        );
      });

      test(
        'send a http request through logging http client and log it',
        () async {
          await loggingHttpClient.get(homeUrl);

          await expectLater(
            loggingHttpClient.logStream,
            emits(const TypeMatcher<List<RequestLogRecord>>()),
          );
        },
      );

      test(
        'rewrites all response fields',
        () async {
          final response = await loggingHttpClient.send(request);

          expect(response.stream, isA<Stream<dynamic>>());
          expect(response.statusCode, statusCode);
          expect(response.contentLength, contentLength);
          expect(response.request, request);
          expect(response.headers, headers);
          expect(response.isRedirect, isRedirect);
          expect(response.persistentConnection, persistentConnection);
          expect(response.reasonPhrase, reasonPhrase);
        },
      );
    },
  );
}
