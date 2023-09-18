import 'package:leancode_notifications_center/src/utils/notifications_payload_deserializer.dart';

class NotificationsConfig {
  NotificationsConfig({
    required NotificationDeserializersMap payloadDeserializers,
  }) : notificationsDeserializer = NotificationsDeserializer(
          deserializers: payloadDeserializers,
        );

  final NotificationsDeserializer notificationsDeserializer;
}
