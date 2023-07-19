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

    setUp(() {
      cqrs = MockCqrs();
      registerFallbackValue(MockQuery());

      PackageInfo.setMockInitialValues(
        appName: "",
        packageName: "",
        version: "1.0.0",
        buildNumber: "0",
        buildSignature: "",
      );

      debugDefaultTargetPlatformOverride = TargetPlatform.android;

      SharedPreferences.setMockInitialValues({});
    });

    testWidgets(
        'show force update screen on second launch if update should be enforced',
        (tester) async {
      registerUpdateRequired(cqrs);

      await pumpForceUpdateGuard(cqrs, tester, const ValueKey(1));
      expectForceUpdatePage(false);

      await pumpForceUpdateGuard(cqrs, tester, const ValueKey(2));
      expectForceUpdatePage(true);

      // Unfortunately, this cannot be reset in teardown / teardownAll, but has
      // to be done in every test separately:
      // https://github.com/flutter/flutter/issues/110488
      debugDefaultTargetPlatformOverride = null;
    });

    testWidgets('do not show force update screen if not required',
        (tester) async {
      registerUpToDate(cqrs);

      await pumpForceUpdateGuard(cqrs, tester, const ValueKey(1));
      expectForceUpdatePage(false);

      await pumpForceUpdateGuard(cqrs, tester, const ValueKey(2));
      expectForceUpdatePage(false);

      debugDefaultTargetPlatformOverride = null;
    });

    testWidgets(
        'show force update screen on next launch if minimum required version changes while the app is open',
        (tester) async {
      registerUpToDate(cqrs);

      await pumpForceUpdateGuard(cqrs, tester, const ValueKey(1));
      expectForceUpdatePage(false);

      await pumpForceUpdateGuard(cqrs, tester, const ValueKey(2));
      expectForceUpdatePage(false);

      registerUpdateRequired(cqrs);

      await tester.pump(ForceUpdateGuard.updateCheckingInterval);

      await pumpForceUpdateGuard(cqrs, tester, const ValueKey(3));
      expectForceUpdatePage(true);

      debugDefaultTargetPlatformOverride = null;
    });

    testWidgets('Suggest update when needed', (tester) async {
      registerUpdateSuggested(cqrs);

      await pumpForceUpdateGuard(cqrs, tester, const ValueKey(1));
      expectSuggestUpdateDialog(false);

      await pumpForceUpdateGuard(cqrs, tester, const ValueKey(2));
      expectSuggestUpdateDialog(false);

      debugDefaultTargetPlatformOverride = null;
    });

    testWidgets('Do not suggest update when not needed', (tester) async {
      registerUpToDate(cqrs);

      await pumpForceUpdateGuard(cqrs, tester, const ValueKey(1));
      expectSuggestUpdateDialog(false);

      await pumpForceUpdateGuard(cqrs, tester, const ValueKey(2));
      expectSuggestUpdateDialog(false);

      debugDefaultTargetPlatformOverride = null;
    });
  });
}
