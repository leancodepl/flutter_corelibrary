import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:leancode_contracts/leancode_contracts.dart';
import 'package:leancode_notifications_center/src/mocks/notifications_mocks.dart';
import 'package:leancode_notifications_center/src/models/notification.dart';
import 'package:leancode_notifications_center/src/utils/notifications_payload_deserializer.dart';
import 'package:logging/logging.dart';

class PaginatedNotificationsCubit extends Cubit<PaginatedNotificationsState> {
  PaginatedNotificationsCubit({
    required NotificationsDeserializer deserializer,
    required Cqrs cqrs,
  })  : _cqrs = cqrs,
        _deserializer = deserializer,
        super(PaginatedNotificationsReadyState());

  final Cqrs _cqrs;
  final NotificationsDeserializer _deserializer;

  static const _pageSize = 10;
  static final _logger = Logger('PaginatedNotificationsCubit');

  Future<void> init() async {
    await maybeFetchNextPage();
  }

  Future<void> refresh() async {
    emit(PaginatedNotificationsReadyState());

    await maybeFetchNextPage();
  }

  Future<void> maybeFetchNextPage() async {
    final state = this.state;
    if (state is! PaginatedNotificationsReadyState ||
        state.busy ||
        state.hasReachedEnd) {
      return;
    }

    emit(
      PaginatedNotificationsReadyState(
        busy: true,
        nextToken: state.nextToken,
        hasReachedEnd: state.hasReachedEnd,
        notifications: state.notifications,
      ),
    );

    try {
      final result = (
        messages: getMockedMessages(null),
        nextToken: 'aa',
      );

      await Future<void>.delayed(const Duration(seconds: 2));

      final deserializedNotifications = _deserializer.deserializeMessages(
        result.messages,
      );

      emit(
        PaginatedNotificationsReadyState(
          nextToken: result.nextToken,
          hasReachedEnd: result.messages.length < _pageSize,
          notifications: [
            ...state.notifications,
            ...deserializedNotifications,
          ],
        ),
      );
    } catch (err, st) {
      emit(PaginatedNotificationsErrorState());

      _logger.info(
        'Notifications fetch failed with network error.',
        err,
        st,
      );
    }
  }
}

sealed class PaginatedNotificationsState {}

class PaginatedNotificationsReadyState extends PaginatedNotificationsState {
  PaginatedNotificationsReadyState({
    this.busy = false,
    this.nextToken,
    this.hasReachedEnd = false,
    this.notifications = const [],
  });

  final bool busy;
  final String? nextToken;
  final bool hasReachedEnd;
  final Iterable<NotificationData> notifications;
}

class PaginatedNotificationsErrorState extends PaginatedNotificationsState {}
