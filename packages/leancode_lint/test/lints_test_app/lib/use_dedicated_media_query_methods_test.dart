// Ignore for test purposes
// ignore_for_file: unnecessary_statements, deprecated_member_use

import 'package:flutter/material.dart';

class FooWidget extends StatelessWidget {
  const FooWidget({super.key});

  @override
  Widget build(BuildContext context) {
    // dart format off
    // expect_lint: use_dedicated_media_query_methods
    final width = MediaQuery.of(context).size
    .width;
    // dart format on

    // expect_lint: use_dedicated_media_query_methods
    final padding = MediaQuery.of(context).padding;

    MediaQuery.of(context).runtimeType;

    MediaQuery.of(context);

    MediaQuery.maybeOf(context);

    // dart format off
    // expect_lint: use_dedicated_media_query_methods
    MediaQuery.maybeOf(context)?.size
    .height;
    // dart format on

    // expect_lint: use_dedicated_media_query_methods
    MediaQuery.maybeOf(context)?.orientation;

    // expect_lint: use_dedicated_media_query_methods
    MediaQuery.maybeOf(context)?.devicePixelRatio;

    // expect_lint: use_dedicated_media_query_methods
    MediaQuery.maybeOf(context)?.textScaleFactor;

    // expect_lint: use_dedicated_media_query_methods
    MediaQuery.maybeOf(context)?.textScaler;

    // expect_lint: use_dedicated_media_query_methods
    MediaQuery.of(context).padding;

    // expect_lint: use_dedicated_media_query_methods
    MediaQuery.maybeOf(context)?.viewInsets;

    // expect_lint: use_dedicated_media_query_methods
    MediaQuery.maybeOf(context)?.systemGestureInsets.bottom;

    // expect_lint: use_dedicated_media_query_methods
    MediaQuery.maybeOf(context)?.alwaysUse24HourFormat;

    // expect_lint: use_dedicated_media_query_methods
    MediaQuery.maybeOf(context)?.accessibleNavigation;

    // expect_lint: use_dedicated_media_query_methods
    MediaQuery.maybeOf(context)?.invertColors.toString();

    // expect_lint: use_dedicated_media_query_methods
    MediaQuery.maybeOf(context)?.highContrast;

    // expect_lint: use_dedicated_media_query_methods
    MediaQuery.maybeOf(context)?.onOffSwitchLabels;

    // expect_lint: use_dedicated_media_query_methods
    MediaQuery.maybeOf(context)?.disableAnimations;

    // expect_lint: use_dedicated_media_query_methods
    MediaQuery.maybeOf(context)?.navigationMode;

    // expect_lint: use_dedicated_media_query_methods
    MediaQuery.maybeOf(context)?.gestureSettings;

    // expect_lint: use_dedicated_media_query_methods
    MediaQuery.maybeOf(context)?.displayFeatures;

    // expect_lint: use_dedicated_media_query_methods
    MediaQuery.maybeOf(context)?.supportsShowingSystemContextMenu;

    return Container(
      // dart format off
      height: 
      // expect_lint: use_dedicated_media_query_methods
      MediaQuery.of(context).size
      .height * 0.8,
      // dart format on
      width: width,
      padding: padding,
    );
  }
}

class FooWithDifferentBuildContextNameWidget extends StatelessWidget {
  const FooWithDifferentBuildContextNameWidget({super.key});

  @override
  Widget build(BuildContext customContextName) {
    // dart format off
    final width = 
    // expect_lint: use_dedicated_media_query_methods
    MediaQuery.of(customContextName).size
    .width;
    // dart format on
    // dart format off
    final padding = 
    // expect_lint: use_dedicated_media_query_methods
    MediaQuery.of(customContextName).padding;
    // dart format on

    MediaQuery.of(customContextName).runtimeType;

    MediaQuery.of(customContextName);

    return Container(
      // dart format off
      height:
      // expect_lint: use_dedicated_media_query_methods
      MediaQuery.of(customContextName).size
      .height * 0.8,
      // dart format on
      width: width,
      padding: padding,
    );
  }
}
