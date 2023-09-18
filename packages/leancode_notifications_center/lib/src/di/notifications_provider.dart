import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:leancode_notifications_center/leancode_notifications_center.dart';

class NotificationsProvider extends StatelessWidget {
  const NotificationsProvider({
    super.key,
    required this.child,
    required this.deserializer,
  });

  final Widget child;

  final NotificationsDeserializer deserializer;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          lazy: false,
          create: (context) => NewNotificationsAmountCubit(
            cqrs: context.read(),
          )..fetch(),
        ),
        BlocProvider(
          lazy: false,
          create: (context) => PaginatedNotificationsCubit(
            cqrs: context.read(),
            deserializer: deserializer,
          )..init(),
        ),
      ],
      child: child,
    );
  }
}
