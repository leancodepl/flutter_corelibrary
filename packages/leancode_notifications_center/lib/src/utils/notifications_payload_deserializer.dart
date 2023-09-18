import 'package:collection/collection.dart';
import 'package:leancode_notifications_center/src/models/notification.dart';
import 'package:leancode_notifications_center/src/models/notification_category.dart';
import 'package:leancode_notifications_center/src/models/raw_notification.dart';

typedef NotificationDeserializersMap
    = Map<String, Object Function(Map<String, dynamic> json)>;

class NotificationsDeserializer {
  NotificationsDeserializer({
    required NotificationDeserializersMap deserializers,
  }) : _deserializers = deserializers;

  final NotificationDeserializersMap _deserializers;

  Iterable<NotificationData> deserializeMessages(
    Iterable<RawNotification> messages,
  ) =>
      messages.map(
        (message) => NotificationData(
          title: message.title,
          content: message.content,
          imageUrl: message.imageUrl,
          category: _tryParseNotificationCategory(message),
          dateTime: message.dateTime,
          payload: _tryDeserializePayload(message),
        ),
      );

  NotificationCategory? _tryParseNotificationCategory(
    RawNotification message,
  ) =>
      mockedCategories.firstWhereOrNull(
        (category) => category.id == message.category,
      );

  Object? _tryDeserializePayload(RawNotification message) {
    try {
      return _deserializers[message.category]?.call(message.payload);
    } catch (err) {
      return null;
    }
  }
}
