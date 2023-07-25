import 'package:flutter/material.dart';
import 'package:lean_analytics/core/core.dart';
import 'package:provider/provider.dart';

abstract class LeanRoute extends MaterialPageRoute<void> {
  LeanRoute(
    this.name, {
    required super.builder,
    required super.settings,
  });

  final String name;
}

class GoRouterNavigationObserver extends NavigatorObserver {
  GoRouterNavigationObserver(this.context);

  final BuildContext context;

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    if (route case LeanRoute()) {
      context.read<LeanAnalytics>().register(
            ScreenViewAnalyticsEvent(
              pageName: route.name,
              screenViewType: ScreenViewType.push,
            ),
          );
    }
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    if (previousRoute != null && previousRoute is LeanRoute) {
      context.read<LeanAnalytics>().register(
            ScreenViewAnalyticsEvent(
              pageName: previousRoute.name,
              screenViewType: ScreenViewType.pop,
            ),
          );
    }
  }

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) {
    if (previousRoute != null && previousRoute is LeanRoute) {
      context.read<LeanAnalytics>().register(
            ScreenViewAnalyticsEvent(
              pageName: previousRoute.name,
              screenViewType: ScreenViewType.pop,
            ),
          );
    }
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    if (newRoute case LeanRoute()) {
      context.read<LeanAnalytics>().register(
            ScreenViewAnalyticsEvent(
              pageName: newRoute.name,
              screenViewType: ScreenViewType.push,
            ),
          );
    }
  }
}
