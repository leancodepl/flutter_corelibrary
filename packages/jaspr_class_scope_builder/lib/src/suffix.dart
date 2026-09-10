/// Six base-36 digits of a hash of [source]: the suffix every class of one
/// scope ends with.
///
/// [source] is the asset a component is declared in, so that two components of
/// the same name in different files never share a namespace.
String classScopeSuffix(String source) {
  var hash = 0x811c9dc5;
  for (final unit in source.codeUnits) {
    hash = _multiply(hash ^ unit, 0x01000193);
  }

  // FNV-1a alone leaves its lowest bits barely stirred — two files whose names
  // differ in one letter can land on suffixes that differ in one digit, or on
  // the same one. Murmur3's finalizer spreads every input bit over all 32.
  hash ^= hash >> 16;
  hash = _multiply(hash, 0x85ebca6b);
  hash ^= hash >> 13;
  hash = _multiply(hash, 0xc2b2ae35);
  hash ^= hash >> 16;

  return (hash % _space).toRadixString(36).padLeft(6, '0');
}

/// [value] times [factor] in 32 bits, multiplied in halves so that no
/// intermediate product exceeds 2^53 and the digits come out the same even
/// where an `int` is a double.
int _multiply(int value, int factor) {
  final low = value & 0xffff;
  final high = value >> 16;

  return (low * factor + ((high * factor & 0xffff) << 16)) & 0xffffffff;
}

/// How many suffixes there are: 36^6, a little over two billion.
const _space = 36 * 36 * 36 * 36 * 36 * 36;
