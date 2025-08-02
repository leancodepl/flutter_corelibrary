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
