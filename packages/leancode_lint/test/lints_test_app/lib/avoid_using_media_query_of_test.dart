// Ignore for test purposes
// ignore_for_file: unnecessary_statements, deprecated_member_use

import 'package:flutter/material.dart';

class FooWidget extends StatelessWidget {
  const FooWidget({super.key});

  @override
  Widget build(BuildContext context) {
    // expect_lint: avoid_using_media_query_of
    final width = MediaQuery.of(context).size.width;

    // expect_lint: avoid_using_media_query_of
    final padding = MediaQuery.of(context).padding;

    MediaQuery.of(context).runtimeType;

    MediaQuery.of(context);

    MediaQuery.maybeOf(context);

    // expect_lint: avoid_using_media_query_of
    MediaQuery.maybeOf(context)?.size.height;

    // expect_lint: avoid_using_media_query_of
    MediaQuery.maybeOf(context)?.orientation;

    // expect_lint: avoid_using_media_query_of
    MediaQuery.maybeOf(context)?.devicePixelRatio;

    // expect_lint: avoid_using_media_query_of
    MediaQuery.maybeOf(context)?.textScaleFactor;

    // expect_lint: avoid_using_media_query_of
    MediaQuery.maybeOf(context)?.textScaler;

    // expect_lint: avoid_using_media_query_of
    MediaQuery.maybeOf(context)?.textScaler;

    // expect_lint: avoid_using_media_query_of
    MediaQuery.of(context).padding;

    // expect_lint: avoid_using_media_query_of
    MediaQuery.maybeOf(context)?.viewInsets;

    // expect_lint: avoid_using_media_query_of
    MediaQuery.maybeOf(context)?.systemGestureInsets;

    // expect_lint: avoid_using_media_query_of
    MediaQuery.maybeOf(context)?.viewPadding;

    // expect_lint: avoid_using_media_query_of
    MediaQuery.maybeOf(context)?.alwaysUse24HourFormat;

    // expect_lint: avoid_using_media_query_of
    MediaQuery.maybeOf(context)?.accessibleNavigation;

    // expect_lint: avoid_using_media_query_of
    MediaQuery.maybeOf(context)?.invertColors;

    // expect_lint: avoid_using_media_query_of
    MediaQuery.maybeOf(context)?.highContrast;

    // expect_lint: avoid_using_media_query_of
    MediaQuery.maybeOf(context)?.onOffSwitchLabels;

    // expect_lint: avoid_using_media_query_of
    MediaQuery.maybeOf(context)?.disableAnimations;

    // expect_lint: avoid_using_media_query_of
    MediaQuery.maybeOf(context)?.navigationMode;

    // expect_lint: avoid_using_media_query_of
    MediaQuery.maybeOf(context)?.gestureSettings;

    // expect_lint: avoid_using_media_query_of
    MediaQuery.maybeOf(context)?.displayFeatures;

    // expect_lint: avoid_using_media_query_of
    MediaQuery.maybeOf(context)?.supportsShowingSystemContextMenu;

    return Container(
      // expect_lint: avoid_using_media_query_of
      height: MediaQuery.of(context).size.height * 0.8,
      width: width,
      padding: padding,
    );
  }
}

class FooWithDifferentBuildContextNameWidget extends StatelessWidget {
  const FooWithDifferentBuildContextNameWidget({super.key});

  @override
  Widget build(BuildContext customContextName) {
    // expect_lint: avoid_using_media_query_of
    final width = MediaQuery.of(customContextName).size.width;

    // expect_lint: avoid_using_media_query_of
    final padding = MediaQuery.of(customContextName).padding;

    MediaQuery.of(customContextName).runtimeType;

    MediaQuery.of(customContextName);

    return Container(
      // expect_lint: avoid_using_media_query_of
      height: MediaQuery.of(customContextName).size.height * 0.8,
      width: width,
      padding: padding,
    );
  }
}
