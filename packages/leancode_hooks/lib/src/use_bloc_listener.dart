import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

/// Takes a [Bloc] or [Cubit] and invokes [listener] in response to state
/// changes in it.
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
