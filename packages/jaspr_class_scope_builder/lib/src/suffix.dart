import 'dart:convert';

import 'package:crypto/crypto.dart';

/// Six base-36 digits of the md5 of [source]: the suffix every class of one
/// scope ends with.
///
/// md5 spreads every input bit over the whole digest, so two files whose names
/// differ in one letter do not end up with suffixes that look related. It is
/// what css-loader hashes CSS module idents with, and nothing here rests on it
/// being hard to reverse.
String classScopeSuffix(String source) {
  final digest = md5.convert(utf8.encode(source)).bytes;
  final value = digest[0] << 24 | digest[1] << 16 | digest[2] << 8 | digest[3];

  return (value % _space).toRadixString(36).padLeft(6, '0');
}

/// How many suffixes there are: 36^6, a little over two billion.
const _space = 36 * 36 * 36 * 36 * 36 * 36;
