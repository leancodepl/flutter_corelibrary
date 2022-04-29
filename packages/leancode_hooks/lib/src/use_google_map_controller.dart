import 'dart:async';

import 'package:discover_rudy/resources/resources.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

// Example copied from Bartek's project.

Completer<GoogleMapController> useGoogleMapController() {
  final context = useContext();
  final brightness = MediaQuery.of(context).platformBrightness;
  final mapCompleter = useMemoized(Completer<GoogleMapController>.new);

  useEffect(
    () {
      mapCompleter.future.then((controller) async {
        final lightStyle = await rootBundle.loadString(Assets.mapStyles.light);
        final darkStyle = await rootBundle.loadString(Assets.mapStyles.dark);

        switch (brightness) {
          case Brightness.light:
            await controller.setMapStyle(lightStyle);
            break;
          case Brightness.dark:
            await controller.setMapStyle(darkStyle);
            break;
        }
      });

      return null;
    },
    [mapCompleter, brightness],
  );

  return mapCompleter;
}
