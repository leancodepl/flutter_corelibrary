import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

/// Helper function to share text with proper UTF-8 encoding.
///
/// This function creates a temporary file with UTF-8 encoding and shares it
/// as text/plain to ensure proper character rendering, especially for
/// non-ASCII characters like Polish letters (Ł, Ń, ą, etc.).
///
/// On web platform or when file sharing fails, it falls back to regular
/// text sharing.
Future<void> shareTextWithEncoding(String text) async {
  if (text.isEmpty) {
    return;
  }

  // On web, use regular share as file system access is limited
  if (kIsWeb) {
    await Share.share(text);
    return;
  }

  try {
    // Create a temporary file with UTF-8 encoding
    final directory = await getTemporaryDirectory();
    final file = File(
      '${directory.path}/shared_log_${DateTime.now().millisecondsSinceEpoch}.txt',
    );

    // Write the text with UTF-8 encoding
    await file.writeAsString(text, encoding: utf8);

    // Share the file with explicit MIME type
    await Share.shareXFiles(
      [XFile(file.path, mimeType: 'text/plain')],
      text: text,
    );

    // Clean up the temporary file after a delay to ensure sharing is complete
    Future.delayed(const Duration(seconds: 5), () {
      if (file.existsSync()) {
        file.deleteSync();
      }
    });
  } catch (e) {
    // Fallback to regular share if file sharing fails
    await Share.share(text);
  }
}
