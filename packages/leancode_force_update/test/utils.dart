import 'package:cqrs/cqrs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:leancode_force_update/data/contracts/contracts.dart';
import 'package:leancode_force_update/leancode_force_update.dart';
import 'package:mocktail/mocktail.dart';

class MockCqrs extends Mock implements Cqrs {}

class MockQuery extends Mock implements Query<VersionSupportDTO> {}

const _forceUpdateScreenKey = Key('ForceUpdateScreen');
const _suggestUpdateDialogKey = Key('SuggestUpdateDialog');

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

Future<void> pumpForceUpdateGuard({
  required Cqrs cqrs,
  required WidgetTester tester,
  required Key key,
  required bool applyResponseImmediately,
  ForceUpdateController? controller,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: ForceUpdateGuard(
          key: key,
          cqrs: cqrs,
          showForceUpdateScreenImmediately: applyResponseImmediately,
          showSuggestUpdateDialogImmediately: applyResponseImmediately,
          controller: controller ??
              ForceUpdateController(
                androidBundleId: '',
                appleAppId: '',
              ),
          forceUpdateScreen: const Text(
            key: _forceUpdateScreenKey,
            'Update required',
          ),
          suggestUpdateDialog: const Dialog(
            key: _suggestUpdateDialogKey,
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
