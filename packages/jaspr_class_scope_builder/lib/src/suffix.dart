/// Six base-36 digits of an FNV-1a hash of [source]: the suffix every class of
/// one scope ends with.
///
/// [source] is the asset a component is declared in, so that two components of
/// the same name in different files never share a namespace.
String classScopeSuffix(String source) {
  var hash = 0x811c9dc5;
  for (final unit in source.codeUnits) {
    hash ^= unit;
    // Multiplied in halves so that no intermediate product exceeds 2^53, and
    // the digits come out the same even where an `int` is a double.
    final low = hash & 0xffff;
    final high = hash >> 16;
    hash =
        (low * 0x01000193 + ((high * 0x01000193 & 0xffff) << 16)) & 0xffffffff;
  }

  // Taken modulo, not truncated: base 36 of a 32-bit hash is six-and-a-bit
  // digits, so cutting it short would crowd the suffixes that begin with a 1.
  return (hash % _space).toRadixString(36).padLeft(6, '0');
}

/// How many suffixes there are: 36^6, a little over two billion.
const _space = 36 * 36 * 36 * 36 * 36 * 36;
