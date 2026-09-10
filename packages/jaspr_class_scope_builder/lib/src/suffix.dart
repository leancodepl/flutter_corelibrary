import 'dart:convert';

import 'package:crypto/crypto.dart';

/// Six base-36 digits of the md5 of [source], the suffix a scope's classes
/// end with. What `md5sum` says, taken modulo 36^6.
String classScopeSuffix(String source) {
  final digest = md5.convert(utf8.encode(source)).bytes;
  final value = digest[0] << 24 | digest[1] << 16 | digest[2] << 8 | digest[3];

  return (value % _space).toRadixString(36).padLeft(6, '0');
}

const _space = 36 * 36 * 36 * 36 * 36 * 36;
