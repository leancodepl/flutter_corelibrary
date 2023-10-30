import 'package:cqrs/cqrs.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:force_update/src/force_update_guard.dart';
import 'package:mocktail/mocktail.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'utils.dart';

void main() {
  group('Force update', () {
    late Cqrs cqrs;

    Future<void> pumpGuard(
      WidgetTester tester,
      int key, {
      bool applyResponseImmediately = false,
    }) {
      return pumpForceUpdateGuard(
        cqrs: cqrs,
        tester: tester,
        applyResponseImmediately: applyResponseImmediately,
        key: ValueKey(key),
      );
    }

    setUp(() {
      cqrs = MockCqrs();
      registerFallbackValue(MockQuery());

      PackageInfo.setMockInitialValues(
        appName: '',
        packageName: '',
        version: '1.0.0',
        buildNumber: '0',
        buildSignature: '',
      );

      debugDefaultTargetPlatformOverride = TargetPlatform.android;

      SharedPreferences.setMockInitialValues({});
    });

    testWidgets(
        'show force update screen on second launch if update should be enforced',
        (tester) async {
      registerUpdateRequired(cqrs);

      await pumpGuard(tester, 1);
      expectForceUpdatePage(value: false);

      await pumpGuard(tester, 2);
      expectForceUpdatePage(value: true);

      // Unfortunately, this cannot be reset in teardown / teardownAll, but has
      // to be done in every test separately:
      // https://github.com/flutter/flutter/issues/110488
      debugDefaultTargetPlatformOverride = null;
    });

    testWidgets(
        'show force update screen on first launch if update should be enforced and showForceUpdateScreenImmediately == true',
        (tester) async {
      registerUpdateRequired(cqrs);

      await pumpGuard(tester, 1, applyResponseImmediately: true);
      expectForceUpdatePage(value: true);

      debugDefaultTargetPlatformOverride = null;
    });

    testWidgets('do not show force update screen if not required',
        (tester) async {
      registerUpToDate(cqrs);

      await pumpGuard(tester, 1);
      expectForceUpdatePage(value: false);

      await pumpGuard(tester, 2);
      expectForceUpdatePage(value: false);

      debugDefaultTargetPlatformOverride = null;
    });

    testWidgets(
        'show force update screen on next launch if minimum required version changes while the app is open',
        (tester) async {
      registerUpToDate(cqrs);

      await pumpGuard(tester, 1);
      expectForceUpdatePage(value: false);

      await pumpGuard(tester, 2);
      expectForceUpdatePage(value: false);

      registerUpdateRequired(cqrs);

      await tester.pump(ForceUpdateGuard.updateCheckingInterval);

      await pumpGuard(tester, 3);
      expectForceUpdatePage(value: true);

      debugDefaultTargetPlatformOverride = null;
    });

    testWidgets('Suggest update on second launch when needed', (tester) async {
      registerUpdateSuggested(cqrs);

      await pumpGuard(tester, 1);
      expectSuggestUpdateDialog(value: false);

      await pumpGuard(tester, 2);
      expectSuggestUpdateDialog(value: true);

      debugDefaultTargetPlatformOverride = null;
    });

    testWidgets(
        'Suggest update on first launch when needed and showSuggestUpdateDialogImmediately == true',
        (tester) async {
      registerUpdateSuggested(cqrs);

      await pumpGuard(tester, 1, applyResponseImmediately: true);
      expectSuggestUpdateDialog(value: true);

      debugDefaultTargetPlatformOverride = null;
    });

    testWidgets('Do not suggest update when not needed', (tester) async {
      registerUpToDate(cqrs);

      await pumpGuard(tester, 1);
      expectSuggestUpdateDialog(value: false);

      await pumpGuard(tester, 2);
      expectSuggestUpdateDialog(value: false);

      debugDefaultTargetPlatformOverride = null;
    });
  });
}
