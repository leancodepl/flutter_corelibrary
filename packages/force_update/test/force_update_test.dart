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
  group('Force update', () {
    late Cqrs cqrs;

    void registerVersionSupportAnswer(VersionSupportDTO dto) {
      when(() => cqrs.get<VersionSupportDTO>(any())).thenAnswer(
        (_) async => dto,
      );
    }

    Future<void> pumpForceUpdate(WidgetTester tester, Key key) async {
      await tester.pumpWidget(
        ForceUpdateGuard(
          key: key,
          cqrs: cqrs,
          child: const SizedBox(),
        ),
      );

      await tester.pump();
    }

    void expectForceUpdatePage(bool value) {
      expect(find.text('Update'), value ? findsOneWidget : findsNothing);
    }

    setUp(() {
      cqrs = MockCqrs();
      registerFallbackValue(MockQuery());
      registerVersionSupportAnswer(
        VersionSupportDTO(
          currentlySupportedVersion: '1.5.0',
          minimumRequiredVersion: '1.2.0',
          result: VersionSupportResultDTO.updateSuggested,
        ),
      );

      debugDefaultTargetPlatformOverride = TargetPlatform.android;

      SharedPreferences.setMockInitialValues({});
    });

    testWidgets(
        'show force update screen on second launch if update should be enforced',
        (tester) async {
      PackageInfo.setMockInitialValues(
        appName: "",
        packageName: "",
        version: "1.0.0",
        buildNumber: "0",
        buildSignature: "",
      );

      await pumpForceUpdate(tester, const ValueKey(1));
      expectForceUpdatePage(false);

      await pumpForceUpdate(tester, const ValueKey(2));
      expectForceUpdatePage(true);

      debugDefaultTargetPlatformOverride = null;
    });

    testWidgets('do not show force update screen if not required',
        (tester) async {
      PackageInfo.setMockInitialValues(
        appName: "",
        packageName: "",
        version: "1.2.0",
        buildNumber: "0",
        buildSignature: "",
      );

      await pumpForceUpdate(tester, const ValueKey(1));
      expectForceUpdatePage(false);

      await pumpForceUpdate(tester, const ValueKey(2));
      expectForceUpdatePage(false);

      // Unfortunately, this cannot be reset in teardown / teardownAll, but has
      // to be done in every test separately:
      // https://github.com/flutter/flutter/issues/110488
      debugDefaultTargetPlatformOverride = null;
    });

    testWidgets(
        'show force update screen on next launch if minimum required version changes while the app is open',
        (tester) async {
      PackageInfo.setMockInitialValues(
        appName: "",
        packageName: "",
        version: "1.2.0",
        buildNumber: "0",
        buildSignature: "",
      );

      await pumpForceUpdate(tester, const ValueKey(1));
      expectForceUpdatePage(false);

      await pumpForceUpdate(tester, const ValueKey(2));
      expectForceUpdatePage(false);

      registerVersionSupportAnswer(
        VersionSupportDTO(
          currentlySupportedVersion: '1.5.0',
          minimumRequiredVersion: '1.3.0',
          result: VersionSupportResultDTO.updateRequired,
        ),
      );

      await tester.pump(ForceUpdateGuard.updateCheckingInterval);

      await pumpForceUpdate(tester, const ValueKey(3));
      expectForceUpdatePage(true);

      debugDefaultTargetPlatformOverride = null;
    });
  });
}
