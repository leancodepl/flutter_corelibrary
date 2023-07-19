extension Compare<T> on Comparable<T> {
  bool operator <=(T other) => compareTo(other) <= 0;
  bool operator >=(T other) => compareTo(other) >= 0;
  bool operator <(T other) => compareTo(other) < 0;
  bool operator >(T other) => compareTo(other) > 0;
}

class AppVersion implements Comparable<AppVersion> {
  const AppVersion({required this.version});

  final String version;

  @override
  int compareTo(other) {
    if (version == other.version) {
      return 0;
    }

    List<int> splitVersion(String version) =>
        version.split('.').map((part) => int.parse(part)).toList();

    final parts = splitVersion(version);
    final otherParts = splitVersion(other.version);

    var i = 0;
    while (i < parts.length && i < otherParts.length) {
      if (parts[i] > otherParts[i]) {
        return 1;
      } else if (parts[i] < otherParts[i]) {
        return -1;
      }

      ++i;
    }

    if (parts.length > otherParts.length) {
      return 1;
    }

    return -1;
  }
}
