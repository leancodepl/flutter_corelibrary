import 'package:cqrs/cqrs.dart';
import 'package:example/force_update_screen.dart';
import 'package:flutter/material.dart';
import 'package:force_update/data/contracts/contracts.dart';
import 'package:force_update/force_update.dart';
import 'package:logging/logging.dart';
import 'package:mocktail/mocktail.dart';

class MockCqrs extends Mock implements Cqrs {}

class MockQuery extends Mock implements Query<VersionSupportDTO> {}

void main() async {
  Logger.root.level = Level.ALL; // defaults to Level.INFO
  Logger.root.onRecord.listen((record) {
    debugPrint('${record.level.name}: ${record.time}: ${record.message}');
  });

  final cqrs = MockCqrs();
  registerFallbackValue(MockQuery());
  when(() => cqrs.get<VersionSupportDTO>(any())).thenAnswer(
    (_) async => VersionSupportDTO(
      currentlySupportedVersion: '1.0.0',
      minimumRequiredVersion: '1.2.0',
      result: VersionSupportResultDTO.updateRequired,
    ),
  );

  runApp(MyApp(cqrs: cqrs));
}

class UpdateInfoDTO {
  const UpdateInfoDTO({required this.minRequiredVersion});

  final String minRequiredVersion;
}

Future<UpdateInfoDTO> fetchUpdatesFromServer() async {
  return const UpdateInfoDTO(minRequiredVersion: '1.1.0');
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, required this.cqrs});

  final Cqrs cqrs;

  @override
  Widget build(BuildContext context) {
    return ForceUpdateGuard<UpdateInfoDTO>(
      cqrs: cqrs,
      forceUpdateScreen: const ForceUpdateScreen(),
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
      body: const Center(child: Text('Homepage')),
    );
  }
}
