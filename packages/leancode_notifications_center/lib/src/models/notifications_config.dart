import 'package:force_update/src/utils/notifications_payload_deserializer.dart';

class NotificationsConfig {
  NotificationsConfig({
    required NotificationDeserializersMap payloadDeserializers,
  }) : notificationsDeserializer = NotificationsDeserializer(
          deserializers: payloadDeserializers,
        );

  final NotificationsDeserializer notificationsDeserializer;
}
