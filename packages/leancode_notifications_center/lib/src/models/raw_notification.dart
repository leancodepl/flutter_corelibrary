import 'package:flutter/material.dart';
import 'package:leancode_contracts/leancode_contracts.dart';

class RawNotification {
  RawNotification({
    required this.title,
    required this.content,
    required this.imageUrl,
    required this.category,
    required this.dateTime,
    this.onTap,
    required this.payload,
  });

  final String title;
  final String? content;
  final Uri? imageUrl;
  final String category;
  final DateTimeOffset dateTime;
  final VoidCallback? onTap;
  final Map<String, dynamic> payload;
}
