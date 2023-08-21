import 'package:bloc/bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

/// Takes a [Bloc] or [Cubit] and invokes [listener] in response to state
/// changes.
void useBlocListener<S>({
  required BlocBase<S> bloc,
  required void Function(S state) listener,
}) {
  useEffect(
    () {
      final subscription = bloc.stream.listen(listener);
      return subscription.cancel;
    },
    [bloc, listener],
  );
}
