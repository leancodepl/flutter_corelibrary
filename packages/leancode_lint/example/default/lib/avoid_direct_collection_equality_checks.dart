// Examples for the `avoid_direct_collection_equality_checks` lint.
//
// This package depends on `flutter` but not on `collection`, so only the
// `listEquals`/`setEquals`/`mapEquals` and `identical` fixes are offered. Add
// `collection: any` to the dependencies in `pubspec.yaml` and run
// `flutter pub get` to see the `const ListEquality().equals` fix appear too —
// the transitive dependency this package already has through `flutter`
// deliberately does not enable it.

// --- Violations ---

bool listsAreEqual(List<int> a, List<int> b) {
  return identical(a, b);
}

bool listsAreNotEqual(List<int> a, List<int> b) {
  return a != b;
}

bool listLiteralsAreEqual() {
  return <int>[1, 2] == <int>[1, 2];
}

bool setsAreEqual(Set<String> a, Set<String> b) {
  return a == b;
}

bool mapsAreEqual(Map<String, int> a, Map<String, int> b) {
  return a == b;
}

bool nullableListsAreEqual(List<int>? a, List<int>? b) {
  return a == b;
}

abstract class IntList implements List<int> {}

bool listSubtypeIsEqualToList(IntList a, List<int> b) {
  return a == b;
}

bool inferredMapsAreEqual() {
  final a = {'x': 1};
  final b = {'x': 1};
  return a == b;
}

// --- No violations ---

bool listIsNull(List<int>? a) {
  return a == null;
}

bool listIsEqualToObject(List<int> a, Object b) {
  return a == b;
}

bool listIsEqualToSet(List<int> a, Set<int> b) {
  // The point here is that the lint stays quiet on mismatched kinds.
  // ignore: unrelated_type_equality_checks
  return a == b;
}

bool scalarsAreEqual(int a, int b) {
  return a == b;
}

class Point {
  const Point(this.x, this.y);

  final int x;
  final int y;

  @override
  bool operator ==(Object other) =>
      other is Point && other.x == x && other.y == y;

  @override
  int get hashCode => Object.hash(x, y);
}

bool pointsAreEqual(Point a, Point b) {
  return a == b;
}
