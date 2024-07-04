// This file mostly consists of code copied from https://pub.dev/packages/shake
// The package must have been vendored in order to bump dependency on
// sensors_plus and avoid exceptions caused by the old version of that package.
// Shake dependency can be brought back once https://github.com/deven98/shake/pull/32
// is merged

import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:sensors_plus/sensors_plus.dart';

class ShakeDetector {
  /// This constructor automatically calls [startListening] and starts detection and callbacks.
  ShakeDetector.autoStart({
    required this.onPhoneShake,
    this.shakeThresholdGravity = 2.7,
    this.shakeSlopTimeMS = 500,
    this.shakeCountResetTime = 3000,
    this.minimumShakeCount = 1,
  }) {
    startListening();
  }

  final VoidCallback onPhoneShake;

  /// Shake detection threshold
  final double shakeThresholdGravity;

  /// Minimum time between shake
  final int shakeSlopTimeMS;

  /// Time before shake count resets
  final int shakeCountResetTime;

  /// Number of shakes required before shake is triggered
  final int minimumShakeCount;

  int mShakeTimestamp = DateTime.now().millisecondsSinceEpoch;
  int mShakeCount = 0;

  StreamSubscription<AccelerometerEvent>? streamSubscription;

  void startListening() {
    streamSubscription = accelerometerEventStream().listen(
      (event) {
        final gX = event.x / 9.80665;
        final gY = event.y / 9.80665;
        final gZ = event.z / 9.80665;

        // gForce will be close to 1 when there is no movement.
        final gForce = sqrt(gX * gX + gY * gY + gZ * gZ);

        if (gForce > shakeThresholdGravity) {
          final now = DateTime.now().millisecondsSinceEpoch;
          // ignore shake events too close to each other (500ms)
          if (mShakeTimestamp + shakeSlopTimeMS > now) {
            return;
          }

          // reset the shake count after [shakeCountResetTime] seconds of no shakes
          if (mShakeTimestamp + shakeCountResetTime < now) {
            mShakeCount = 0;
          }

          mShakeTimestamp = now;
          mShakeCount++;

          if (mShakeCount >= minimumShakeCount) {
            onPhoneShake();
          }
        }
      },
    );
  }

  void stopListening() {
    streamSubscription?.cancel();
  }
}
