/// Base class for contracts that can be serialized and sent to the backend.
abstract class Contractable {
  /// Returns a JSON-encoded representation of the data this class carries.
  Map<String, dynamic> toJson();

  /// Returns a full name of this contractable, usually that is a fully
  /// qualified class name of the backend class.
  String getFullName();

  /// Returns a prefix applied before the full name of the contractable when
  /// sending a request to the backend.
  String pathPrefix;
}

/// Query describing a criteria for a query and the results it returns.
abstract class Query<T> implements Contractable {
  /// Returns a result of type [T] deserialzied from the [json].
  T resultFactory(dynamic json);

  @override
  String get pathPrefix => 'query';
}

/// Command carrying data related to performing a certain action on the backend.
abstract class Command implements Contractable {
  @override
  String get pathPrefix => 'command';
}
