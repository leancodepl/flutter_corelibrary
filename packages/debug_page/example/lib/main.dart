import 'package:flutter/material.dart';
import 'package:debug_page/debug_page.dart';

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

  Future<void> _sendRequest() async {
    await loggingHttpClient.get(
      Uri.parse('https://leancode.co'),
      headers: {
        'User-Agent': 'Simulator',
        'Authorization': 'Bearer ABC',
      },
    );
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
