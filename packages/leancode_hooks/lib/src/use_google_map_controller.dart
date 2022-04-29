import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

/// Returns a dark-mode aware [GoogleMapController].
Completer<GoogleMapController> useGoogleMapController({
  required String lightStylePath,
  required String darkStylePath,
}) {
  final context = useContext();
  final brightness = MediaQuery.of(context).platformBrightness;
  final mapCompleter = useMemoized(Completer<GoogleMapController>.new);

  final lightStyleFuture = useMemoized(
    () => rootBundle.loadString(lightStylePath),
  );

  final darkStyleFuture = useMemoized(
    () => rootBundle.loadString(darkStylePath),
  );

  final lightStyleSnapshot = useFuture(lightStyleFuture);
  final darkStyleSnapshot = useFuture(darkStyleFuture);

  useEffect(
    () {
      var ready = false;
      if (lightStyleSnapshot.hasData && darkStyleSnapshot.hasData) {
        ready = true;
      }

      if (!ready) {
        return null;
      }

      // register callback only when ready
      mapCompleter.future.then((controller) async {
        switch (brightness) {
          case Brightness.light:
            await controller.setMapStyle(lightStyleSnapshot.data);
            break;
          case Brightness.dark:
            await controller.setMapStyle(darkStyleSnapshot.data);
            break;
        }
      });

      return null;
    },
    [mapCompleter, brightness, lightStyleSnapshot.data, darkStyleSnapshot.data],
  );

  return mapCompleter;
}
