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
  const forceUpdate = ForceUpdate(
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
        result: VersionSupportResultDTO.updateSuggested,
      ));
    },
  );

  runApp(MyApp(
    forceUpdate: forceUpdate,
    cqrs: cqrs,
  ));
}

final _navigatorKey = GlobalKey<NavigatorState>();

class MyApp extends StatelessWidget {
  const MyApp({
    super.key,
    required ForceUpdate forceUpdate,
    required Cqrs cqrs,
  })  : _forceUpdate = forceUpdate,
        _cqrs = cqrs;

  final ForceUpdate _forceUpdate;
  final Cqrs _cqrs;

  @override
  Widget build(BuildContext context) {
    return ForceUpdateGuard(
      dialogContextKey: _navigatorKey,
      cqrs: _cqrs,
      suggestUpdateDialog: SuggestUpdateDialog(forceUpdate: _forceUpdate),
      forceUpdateScreen: ForceUpdateScreen(forceUpdate: _forceUpdate),
      child: MaterialApp(
        navigatorKey: _navigatorKey,
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
