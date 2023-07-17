import 'package:cqrs/cqrs.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:force_update/data/contracts/contracts.dart';
import 'package:force_update/src/force_update_guard.dart';
import 'package:mocktail/mocktail.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MockCqrs extends Mock implements Cqrs {}

class MockQuery extends Mock implements Query<VersionSupportDTO> {}

void main() {
  testWidgets('Test force update', (tester) async {
    final cqrs = MockCqrs();
    registerFallbackValue(MockQuery());
    when(() => cqrs.get<VersionSupportDTO>(any())).thenAnswer(
      (_) async => VersionSupportDTO(
        currentlySupportedVersion: '1.5.0',
        minimumRequiredVersion: '1.2.0',
        result: VersionSupportResultDTO.updateSuggested,
      ),
    );

    debugDefaultTargetPlatformOverride = TargetPlatform.android;

    PackageInfo.setMockInitialValues(
      appName: "",
      packageName: "",
      version: "1.0.0",
      buildNumber: "0",
      buildSignature: "",
    );

    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(
      ForceUpdateGuard(
        key: const ValueKey(1),
        cqrs: cqrs,
        child: const SizedBox(),
      ),
    );

    await tester.pump();

    expect(find.text('Update'), findsNothing);

    await tester.pumpWidget(
      ForceUpdateGuard(
        key: const ValueKey(2),
        cqrs: cqrs,
        child: const SizedBox(),
      ),
    );

    await tester.pump();

    expect(find.text('Update'), findsOneWidget);

    debugDefaultTargetPlatformOverride = null;
  });
}
