import 'package:cqrs/cqrs.dart';
import 'package:example/force_update_screen.dart';
import 'package:example/suggest_update_dialog.dart';
import 'package:flutter/material.dart';
import 'package:force_update/data/contracts/contracts.dart';
import 'package:force_update/force_update.dart';
import 'package:mocktail/mocktail.dart';

class MockCqrs extends Mock implements Cqrs {}

class MockQuery extends Mock implements Query<VersionSupportDTO> {}

void main() async {
  final forceUpdateController = ForceUpdateController(
    androidBundleId: 'com.example.example',
    appleAppId: '1111111111',
  );

  final cqrs = MockCqrs();
  registerFallbackValue(MockQuery());
  when(() => cqrs.get<VersionSupportDTO>(any())).thenAnswer(
    (_) async {
      return QuerySuccess(VersionSupportDTO(
        currentlySupportedVersion: '1.0.0',
        minimumRequiredVersion: '1.2.0',
        result: VersionSupportResultDTO.upToDate,
      ));
    },
  );

  runApp(MyApp(
    forceUpdateController: forceUpdateController,
    cqrs: cqrs,
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({
    super.key,
    required ForceUpdateController forceUpdateController,
    required Cqrs cqrs,
  })  : _forceUpdateController = forceUpdateController,
        _cqrs = cqrs;

  final ForceUpdateController _forceUpdateController;
  final Cqrs _cqrs;

  @override
  Widget build(BuildContext context) {
    return ForceUpdateGuard(
      cqrs: _cqrs,
      suggestUpdateDialog: SuggestUpdateDialog(
        forceUpdateController: _forceUpdateController,
      ),
      forceUpdateScreen: ForceUpdateScreen(
        forceUpdateController: _forceUpdateController,
      ),
      controller: _forceUpdateController,
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
