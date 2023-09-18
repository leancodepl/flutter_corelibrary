import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logging/logging.dart';

class NewNotificationsAmountCubit extends Cubit<NotificationsAmountState> {
  NewNotificationsAmountCubit() : super(NotificationsAmountInitialState());

  static final _logger = Logger('NotificationsAmountCubit');

  Future<void> fetch() async {
    final state = this.state;
    if (state case NotificationsAmountReadyState(busy: true)) {
      return;
    }

    emit(NotificationsAmountReadyState(busy: true, counter: 0));

    try {
      // TODO: Implement this
      const result = 5;

      emit(NotificationsAmountReadyState(counter: result));
    } catch (err, st) {
      emit(NotificationsAmountErrorState());

      _logger.info(
        'Notifications fetch failed with network error.',
        err,
        st,
      );
    }
  }

  Future<void> updateNotificationsViewTime() async {
    // TODO: Implement this

    emit(NotificationsAmountReadyState(counter: 0));
  }
}

sealed class NotificationsAmountState {}

class NotificationsAmountInitialState extends NotificationsAmountState {}

class NotificationsAmountReadyState extends NotificationsAmountState {
  NotificationsAmountReadyState({
    this.busy = false,
    required this.counter,
  });

  final bool busy;
  final int counter;
}

class NotificationsAmountErrorState extends NotificationsAmountState {}
