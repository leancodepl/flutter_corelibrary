import 'dart:math';

import 'package:example/util.dart';
import 'package:flutter/material.dart';
import 'package:debug_page/debug_page.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Debug Page Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Debug Page Demo Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({
    super.key,
    required this.title,
  });

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  _MyHomePageState() : loggingHttpClient = LoggingHttpClient();

  final LoggingHttpClient loggingHttpClient;

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
    final response = await loggingHttpClient.send(request);
    // `http.Response.fromStream` has to be called in order to make response
    // body appear in the LogsInspector. This is done automatically when using
    // higher-level methods of `http.Client` such as `get` / `post`, but needs
    // to be done manually with `send`
    await http.Response.fromStream(response);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Push the button to send a request'),
              Expanded(
                child: DebugPage(loggingHttpClient: loggingHttpClient),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _sendRequest,
        tooltip: 'Send a request',
        child: const Icon(Icons.send),
      ),
    );
  }
}
