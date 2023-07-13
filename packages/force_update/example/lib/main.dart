import 'package:flutter/material.dart';
import 'package:force_update/force_update.dart';
import 'package:logging/logging.dart';

void main() {
  Logger.root.level = Level.ALL; // defaults to Level.INFO
  Logger.root.onRecord.listen((record) {
    debugPrint('${record.level.name}: ${record.time}: ${record.message}');
  });

  runApp(const MyApp());
}

class UpdateInfoDTO {
  const UpdateInfoDTO({required this.minRequiredVersion});

  final String minRequiredVersion;
}

Future<UpdateInfoDTO> fetchUpdatesFromServer() async {
  return const UpdateInfoDTO(minRequiredVersion: '1.1.0');
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ForceUpdateGuard<UpdateInfoDTO>(
      fetchUpdatesInfo: fetchUpdatesFromServer,
      parseResponse: (dto) async {
        return ForceUpdateResponse(
          minRequiredVersion: dto.minRequiredVersion,
        );
      },
      child: MaterialApp(
        title: 'Force update demo',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: const MyHomePage(title: 'Force update demo page'),
      ),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(title),
      ),
      body: const Center(child: Text('App')),
    );
  }
}
