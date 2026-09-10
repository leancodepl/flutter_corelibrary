import 'dart:convert';

/// Six base-36 digits of the MurmurHash3 (x86_32) of [source]: the suffix
/// every class of one scope ends with.
///
/// [source] is the asset a component is declared in, so that two components of
/// the same name in different files never share a namespace. Murmur spreads
/// every input bit over all 32 output bits, so two files whose names differ in
/// one letter do not end up with suffixes that look related.
String classScopeSuffix(String source) =>
    (_murmur3(utf8.encode(source)) % _space).toRadixString(36).padLeft(6, '0');

/// How many suffixes there are: 36^6, a little over two billion.
const _space = 36 * 36 * 36 * 36 * 36 * 36;

/// MurmurHash3 x86_32 over [bytes], seeded with 0.
int _murmur3(List<int> bytes) {
  const c1 = 0xcc9e2d51;
  const c2 = 0x1b873593;

  var hash = 0;
  final blocks = bytes.length ~/ 4;

  for (var i = 0; i < blocks; i++) {
    final start = i * 4;
    var k =
        bytes[start] |
        bytes[start + 1] << 8 |
        bytes[start + 2] << 16 |
        bytes[start + 3] << 24;

    k = _multiply(_rotateLeft(_multiply(k, c1), 15), c2);
    hash = (_multiply(_rotateLeft(hash ^ k, 13), 5) + 0xe6546b64) & _mask;
  }

  // The last one to three bytes, which no block covered.
  var tail = 0;
  for (var i = bytes.length - 1; i >= blocks * 4; i--) {
    tail = tail << 8 | bytes[i];
  }
  if (tail != 0) {
    hash ^= _multiply(_rotateLeft(_multiply(tail, c1), 15), c2);
  }

  hash ^= bytes.length;
  hash ^= hash >> 16;
  hash = _multiply(hash, 0x85ebca6b);
  hash ^= hash >> 13;
  hash = _multiply(hash, 0xc2b2ae35);

  return (hash ^ hash >> 16) & _mask;
}

const _mask = 0xffffffff;

int _rotateLeft(int value, int bits) =>
    (value << bits | (value & _mask) >> (32 - bits)) & _mask;

/// [value] times [factor] in 32 bits, multiplied in halves so that no
/// intermediate product exceeds 2^53 and the digits come out the same even
/// where an `int` is a double.
int _multiply(int value, int factor) {
  final low = value & 0xffff;
  final high = (value & _mask) >> 16;

  return (low * factor + ((high * factor & 0xffff) << 16)) & _mask;
}
