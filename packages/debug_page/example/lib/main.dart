import 'dart:math';

import 'package:example/util.dart';
import 'package:flutter/material.dart';
import 'package:debug_page/debug_page.dart';
import 'package:http/http.dart' as http;
import 'package:logging/logging.dart';

void main() {
  // This is necessary if you want to instantiate a DebugPage before calling
  // runApp()
  WidgetsFlutterBinding.ensureInitialized();

  final loggingHttpClient = LoggingHttpClient();
  final debugPage = DebugPage(loggingHttpClient: loggingHttpClient);

  runApp(MyApp(
    loggingHttpClient: loggingHttpClient,
    debugPage: debugPage,
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({
    super.key,
    required LoggingHttpClient loggingHttpClient,
    required DebugPage debugPage,
  })  : _loggingHttpClient = loggingHttpClient,
        _debugPage = debugPage;

  final LoggingHttpClient _loggingHttpClient;
  final DebugPage _debugPage;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Debug Page Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: DebugPageOverlay(
        debugPage: _debugPage,
        child: MyHomePage(
          title: 'Flutter Debug Page Demo Page',
          loggingHttpClient: _loggingHttpClient,
        ),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({
    super.key,
    required this.title,
    required this.loggingHttpClient,
  });

  final String title;
  final LoggingHttpClient loggingHttpClient;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  _MyHomePageState();

  final _logger = Logger('MyHomePage');

  static final _requests = [
    http.Request('GET', Uri.parse('https://leancode.co/manifest.json')),
    http.Request('GET', Uri.parse('https://leancode.co/api/job-titles')),
    http.Request(
      'GET',
      Uri.parse(
        'https://leancodelanding2.cdn.prismic.io/api/v2',
      ),
    ),
    http.Request('GET', Uri.parse('https://leancode.co')),
    http.Request('POST', Uri.parse('https://leancode.co'))
      ..body = {'some key': 'some value'}.toString(),
    http.Request('GET', Uri.parse('https://leancode.co/non-existing-path')),
  ];

  Future<void> _sendRequest() async {
    final random = Random();
    final request = copyRequest(_requests[random.nextInt(_requests.length)]);
    final response = await widget.loggingHttpClient.send(request);
    // `http.Response.fromStream` has to be called in order to make response
    // body appear in the LogsInspector. This is done automatically when using
    // higher-level methods of `http.Client` such as `get` / `post`, but needs
    // to be done manually with `send`
    await http.Response.fromStream(response);

    if (response.statusCode < 400) {
      _logger.info(
        'Received a response from remote server (${response.statusCode})',
      );
    } else {
      _logger.severe('Request failed with status code ${response.statusCode}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () => showDialog(
                  context: context,
                  builder: (context) => const Dialog(
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: Text(
                        'Debug page overlay button is still clickable even when dialogs are shown',
                      ),
                    ),
                  ),
                ),
                child: const Text('Show a dialog'),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  Overlay.of(context).insert(
                    OverlayEntry(
                      opaque: true,
                      builder: (context) => Container(
                        color: Colors.red,
                      ),
                    ),
                    below: debugPageOverlayState.currentState?.overlayEntry,
                  );
                },
                child: const Text('Show an overlay'),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        label: const Text('Send request'),
        icon: const Icon(Icons.send),
        tooltip: 'Send a request',
        onPressed: _sendRequest,
      ),
    );
  }
}
