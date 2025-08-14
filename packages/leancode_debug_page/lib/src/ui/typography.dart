import 'package:flutter/material.dart';

class DebugPageTypography {
  static TextStyle _getTextStyle(double fontSize) => TextStyle(
        fontSize: fontSize,
      );

  static TextStyle get small => _getTextStyle(12);
  static TextStyle get medium => _getTextStyle(16);
  static TextStyle get large => _getTextStyle(20);

  static TextStyle get codeBlock => _getTextStyle(12).copyWith(
        fontFamily: 'monospace',
        fontFamilyFallback: ['Monaco', 'Courier'],
      );
}
