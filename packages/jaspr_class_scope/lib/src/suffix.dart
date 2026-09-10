/// Five base-36 digits of an FNV-1a hash of [source]: the same on every
/// platform, machine and version of this package, and short enough to read in
/// the inspector.
///
/// What a scope hashes is its name, or — when the scope comes from
/// `jaspr_class_scope_builder` — the file the component is declared in, so that
/// two components of the same name never share a namespace.
String classScopeSuffix(String source) {
  var hash = 0x811c9dc5;
  for (final unit in source.codeUnits) {
    hash ^= unit;
    // The multiplication is done in halves so that no intermediate product
    // exceeds 2^53: on the web an `int` is a double, and a plain `hash * prime`
    // would round there but not on the VM, handing the same component two
    // different suffixes.
    final low = hash & 0xffff;
    final high = hash >> 16;
    hash =
        (low * 0x01000193 + ((high * 0x01000193 & 0xffff) << 16)) & 0xffffffff;
  }

  return hash.toRadixString(36).padLeft(5, '0').substring(0, 5);
}
