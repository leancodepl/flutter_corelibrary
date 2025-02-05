import 'package:cqrs/cqrs.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:leancode_force_update/data/contracts/contracts.dart';
import 'package:leancode_force_update/src/force_update_guard.dart';
import 'package:leancode_force_update/src/force_update_storage.dart';
import 'package:mocktail/mocktail.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:version/version.dart';

import 'utils.dart';

void main() {
  group('Force update', () {
    late Cqrs cqrs;
    late ForceUpdateController controller;
    const currentVersion = '1.0.0';

    setUp(() {
      cqrs = MockCqrs();
      registerFallbackValue(MockQuery());

      controller = ForceUpdateController(
        androidBundleId: '',
        appleAppId: '',
      );

      PackageInfo.setMockInitialValues(
        appName: '',
        packageName: '',
        version: currentVersion,
        buildNumber: '0',
        buildSignature: '',
      );

      debugDefaultTargetPlatformOverride = TargetPlatform.android;

      SharedPreferences.setMockInitialValues({});
    });

    Future<void> pumpGuard(
      WidgetTester tester,
      int key, {
      required bool applyResponseImmediately,
    }) {
      return pumpForceUpdateGuard(
        cqrs: cqrs,
        tester: tester,
        applyResponseImmediately: applyResponseImmediately,
        controller: controller,
        key: ValueKey(key),
      );
    }

    testWidgets(
        'show force update screen on second launch if update should be enforced',
        (tester) async {
      registerUpdateRequired(cqrs);

      await pumpGuard(tester, 1, applyResponseImmediately: false);
      expectForceUpdatePage(value: false);

      await pumpGuard(tester, 2, applyResponseImmediately: false);
      expectForceUpdatePage(value: true);

      // Unfortunately, this cannot be reset in teardown / teardownAll, but has
      // to be done in every test separately:
      // https://github.com/flutter/flutter/issues/110488
      debugDefaultTargetPlatformOverride = null;
    });

    testWidgets(
        'show force update screen on first launch if update should be enforced, showForceUpdateScreenImmediately == true',
        (tester) async {
      registerUpdateRequired(cqrs);

      await pumpGuard(tester, 1, applyResponseImmediately: true);
      expectForceUpdatePage(value: true);

      debugDefaultTargetPlatformOverride = null;
    });

    testWidgets('do not show force update screen if not required',
        (tester) async {
      registerUpToDate(cqrs);

      await pumpGuard(tester, 1, applyResponseImmediately: false);
      expectForceUpdatePage(value: false);

      await pumpGuard(tester, 2, applyResponseImmediately: false);
      expectForceUpdatePage(value: false);

      debugDefaultTargetPlatformOverride = null;
    });

    testWidgets(
        'show force update screen on next launch if minimum required version changes while the app is open',
        (tester) async {
      registerUpToDate(cqrs);

      await pumpGuard(tester, 1, applyResponseImmediately: false);
      expectForceUpdatePage(value: false);

      await pumpGuard(tester, 2, applyResponseImmediately: false);
      expectForceUpdatePage(value: false);

      registerUpdateRequired(cqrs);

      await tester.pump(ForceUpdateGuard.updateCheckingInterval);

      await pumpGuard(tester, 3, applyResponseImmediately: false);
      expectForceUpdatePage(value: true);

      debugDefaultTargetPlatformOverride = null;
    });

    testWidgets('Suggest update on second launch when needed', (tester) async {
      registerUpdateSuggested(cqrs);

      await pumpGuard(tester, 1, applyResponseImmediately: false);
      expectSuggestUpdateDialog(value: false);

      await pumpGuard(tester, 2, applyResponseImmediately: false);
      expectSuggestUpdateDialog(value: true);

      debugDefaultTargetPlatformOverride = null;
    });

    testWidgets(
        'Suggest update on first launch when needed and showSuggestUpdateDialogImmediately == true, hide dialog properly',
        (tester) async {
      registerUpdateSuggested(cqrs);

      await pumpGuard(
        tester,
        1,
        applyResponseImmediately: true,
      );
      expectSuggestUpdateDialog(value: true);

      controller.hideSuggestDialog();
      await tester.pump();
      expectSuggestUpdateDialog(value: false);

      debugDefaultTargetPlatformOverride = null;
    });

    testWidgets('Do not suggest update when not needed', (tester) async {
      registerUpToDate(cqrs);

      await pumpGuard(tester, 1, applyResponseImmediately: false);
      expectSuggestUpdateDialog(value: false);

      await pumpGuard(tester, 2, applyResponseImmediately: false);
      expectSuggestUpdateDialog(value: false);

      debugDefaultTargetPlatformOverride = null;
    });

    testWidgets(
        'Show force update screen if currently fetched result says to do it and showForceUpdateScreenImmediately == true, regardless of stored result',
        (tester) async {
      registerUpdateRequired(cqrs);
      await ForceUpdateStorage().writeResult(
        ForceUpdateResult(
          versionAtTimeOfRequest: Version.parse(currentVersion),
          conclusion: VersionSupportResultDTO.updateSuggested,
        ),
      );

      await pumpGuard(
        tester,
        1,
        applyResponseImmediately: true,
      );
      expectForceUpdatePage(value: true);

      debugDefaultTargetPlatformOverride = null;
    });
  });
}
