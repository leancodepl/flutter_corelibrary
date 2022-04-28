import 'dart:async';

import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

Completer<GoogleMapController> useGoogleMapController() {
  final mapCompleter = useMemoized(Completer<GoogleMapController>.new);
  return mapCompleter;
}
