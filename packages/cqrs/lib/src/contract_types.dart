import 'transport_types.dart';

/// A generic interface describing a query and its result.
abstract class IRemoteQuery<T> extends Query<T> {}

// A command interface.
abstract class IRemoteCommand extends Command {}
