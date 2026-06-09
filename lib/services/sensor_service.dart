import 'dart:async';

import 'package:sensors_plus/sensors_plus.dart';

class SensorService {
  static final SensorService instance = SensorService();

  int shakeCount = 0;
  int stepCount = 0;

  StreamSubscription? accelerometerSub;
  StreamSubscription? gyroscopeSub;

  void startListening({
    Function(int)? onShakeChanged,
    Function(int)? onStepChanged,
  }) {
    accelerometerSub = accelerometerEventStream().listen((event) {
      double total = event.x.abs() + event.y.abs() + event.z.abs();

      if (total > 35) {
        shakeCount++;
        if (onShakeChanged != null) onShakeChanged(shakeCount);
      } else if (total > 15 && total <= 35) {
        // Basic pedometer simulation using accelerometer spikes
        stepCount++;
        if (onStepChanged != null) onStepChanged(stepCount);
      }
    });

    gyroscopeSub = gyroscopeEventStream().listen((event) {
      double rotation = event.x.abs() + event.y.abs() + event.z.abs();

      if (rotation > 8) {
        shakeCount++;
        if (onShakeChanged != null) onShakeChanged(shakeCount);
      }
    });
  }

  void reset() {
    shakeCount = 0;
    stepCount = 0;
  }

  void stop() {
    accelerometerSub?.cancel();
    gyroscopeSub?.cancel();
  }
}