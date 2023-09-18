import 'package:flutter/material.dart';
import 'package:force_update/src/cubits/paginated_notifications_cubit.dart';

import 'package:leancode_hooks/leancode_hooks.dart';
import 'package:provider/provider.dart';

const _extentAfterTreshold = 500;

void usePaginatedNotificationsController(ScrollController scrollController) {
  final context = useContext();

  final cubit = context.read<PaginatedNotificationsCubit>();

  useEffect(
    () {
      void paginationListener() {
        final hasReachedEnd = switch (cubit.state) {
          PaginatedNotificationsReadyState(:final hasReachedEnd) =>
            hasReachedEnd,
          PaginatedNotificationsErrorState() => true,
        };

        if (!hasReachedEnd &&
            scrollController.position.extentAfter < _extentAfterTreshold) {
          cubit.maybeFetchNextPage();
        }
      }

      scrollController.addListener(paginationListener);

      return () => scrollController.removeListener(paginationListener);
    },
    [],
  );
}
