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
      home: MyHomePage(title: 'Flutter Debug Page Demo Page'),
    );
  }
}

class MyHomePage extends StatelessWidget {
  MyHomePage({
    super.key,
    required this.title,
  }) : loggingHttpClient = LoggingHttpClient();

  final String title;
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
  ];

  Future<void> _sendRequest() async {
    final random = Random();
    final request = copyRequest(_requests[random.nextInt(_requests.length)]);
    await loggingHttpClient.send(request);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Push the button to send a request'),
            Expanded(
              child: LogsInspector(loggingHttpClient: loggingHttpClient),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: (_sendRequest),
        tooltip: 'Send a request',
        child: const Icon(Icons.send),
      ),
    );
  }
}
