import 'package:cqrs/cqrs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:force_update/data/contracts/contracts.dart';
import 'package:force_update/force_update.dart';
import 'package:mocktail/mocktail.dart';

class MockCqrs extends Mock implements Cqrs {}

class MockQuery extends Mock implements Query<VersionSupportDTO> {}

const _forceUpdateScreenKey = Key('ForceUpdateScreen');
const _suggestUpdateDialogKey = Key('SuggestUpdateKey');

void registerVersionSupportAnswer(Cqrs cqrs, VersionSupportDTO dto) {
  when(() => cqrs.get<VersionSupportDTO>(any())).thenAnswer(
    (_) async => QuerySuccess(dto),
  );
}

void registerUpdateRequired(Cqrs cqrs) => registerVersionSupportAnswer(
      cqrs,
      VersionSupportDTO(
        currentlySupportedVersion: '1.5.0',
        minimumRequiredVersion: '1.3.0',
        result: VersionSupportResultDTO.updateRequired,
      ),
    );

void registerUpdateSuggested(Cqrs cqrs) => registerVersionSupportAnswer(
      cqrs,
      VersionSupportDTO(
        currentlySupportedVersion: '1.5.0',
        minimumRequiredVersion: '1.0.0',
        result: VersionSupportResultDTO.updateSuggested,
      ),
    );

void registerUpToDate(Cqrs cqrs) => registerVersionSupportAnswer(
      cqrs,
      VersionSupportDTO(
        currentlySupportedVersion: '1.0.0',
        minimumRequiredVersion: '1.0.0',
        result: VersionSupportResultDTO.upToDate,
      ),
    );

Future<void> pumpForceUpdateGuard(
  Cqrs cqrs,
  WidgetTester tester,
  Key key,
) async {
  final scaffoldKey = GlobalKey<ScaffoldState>();

  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        key: scaffoldKey,
        body: ForceUpdateGuard(
          key: key,
          dialogContextKey: scaffoldKey,
          cqrs: cqrs,
          forceUpdateScreen: const Text(
            key: Key('ForceUpdateScreen'),
            'Update required',
          ),
          suggestUpdateDialog: const Dialog(
            key: Key('SuggestUpdateDialog'),
            child: Text('Update suggested'),
          ),
          child: const SizedBox(),
        ),
      ),
    ),
  );

  await tester.pump();
}

void expectForceUpdatePage({required bool value}) {
  expect(
    find.byKey(_forceUpdateScreenKey),
    value ? findsOneWidget : findsNothing,
  );
}

void expectSuggestUpdateDialog({required bool value}) {
  expect(
    find.byKey(_suggestUpdateDialogKey),
    value ? findsOneWidget : findsNothing,
  );
}
