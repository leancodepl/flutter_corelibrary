import 'dart:math';

import 'package:example/util.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:leancode_debug_page/leancode_debug_page.dart';
import 'package:logging/logging.dart';

void main() {
  final loggingHttpClient = LoggingHttpClient();

  runApp(MyApp(loggingHttpClient: loggingHttpClient));
}

class MyApp extends StatefulWidget {
  const MyApp({
    super.key,
    required LoggingHttpClient loggingHttpClient,
  }) : _loggingHttpClient = loggingHttpClient;

  final LoggingHttpClient _loggingHttpClient;

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  _MyAppState();

  late DebugPageController _debugPageController;

  @override
  void initState() {
    super.initState();

    _debugPageController = DebugPageController(
      showEntryButton: true,
      loggingHttpClient: widget._loggingHttpClient,
    );
  }

  @override
  Widget build(BuildContext context) {
    return DebugPageOverlay(
      controller: _debugPageController,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Debug Page Demo',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: MyHomePage(
          title: 'Flutter Debug Page Demo Page',
          loggingHttpClient: widget._loggingHttpClient,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _debugPageController.dispose();

    super.dispose();
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
  _MyHomePageState() : loggingHttpClient = LoggingHttpClient() {
    debugPageController = DebugPageController(
      loggingHttpClient: loggingHttpClient,
    );
  }

  final LoggingHttpClient loggingHttpClient;
  late DebugPageController debugPageController;
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
    final randomIndex = Random().nextInt(_requests.length);
    final request = copyRequest(_requests[randomIndex]);
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

    if (randomIndex % 3 == 0) {
      _logger.info('Some very long log' * 100);
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
                      child: Text('Some dialog'),
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
                        alignment: Alignment.center,
                        child: const Material(
                          color: Colors.transparent,
                          child: Text(
                            'Overlay',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
                child: const Text('Show an overlay'),
              ),
            ],
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
      floatingActionButton: FloatingActionButton.extended(
        label: const Text('Send request'),
        icon: const Icon(Icons.send),
        tooltip: 'Send a request',
        onPressed: _sendRequest,
      ),
    );
  }
}
