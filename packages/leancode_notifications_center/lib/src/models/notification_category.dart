import 'package:flutter/material.dart';

class NotificationCategory {
  NotificationCategory({
    required this.id,
    required this.icon,
  });

  final String id;

  final IconData icon;
}

final mockedCategories = [
  NotificationCategory(
    id: 'NewMessageReceived',
    icon: Icons.chat_bubble_outline,
  ),
  NotificationCategory(
    id: 'YourPostWasLiked',
    icon: Icons.thumb_up_alt_outlined,
  ),
  NotificationCategory(
    id: 'SaleStarted',
    icon: Icons.discount_outlined,
  ),
];
