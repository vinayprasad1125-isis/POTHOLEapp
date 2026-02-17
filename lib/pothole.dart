import 'dart:async';
import 'dart:math';
import 'package:sensors_plus/sensors_plus.dart';

class PotholeDetector {
  // Lowered a bit for hand simulation
  static const double magnitudeThreshold = 10;
  static const double zSpikeThreshold = 5;
  static const double jerkThreshold = 12;
  static const int cooldownMs = 800;

  double _lastMagnitude = 0;
  DateTime _lastDetection = DateTime.now();
  StreamSubscription? _subscription;

  void startListening(
    Function(double x, double y, double z) onData,
    Function() onPotholeDetected,
  ) {
    _subscription = accelerometerEvents.listen((event) {
      final x = event.x;
      final y = event.y;
      final z = event.z;

      onData(x, y, z);

      final magnitude = sqrt(x * x + y * y + z * z);
      final jerk = (magnitude - _lastMagnitude).abs();
      _lastMagnitude = magnitude;

      final now = DateTime.now();
      if (now.difference(_lastDetection).inMilliseconds < cooldownMs) return;

      if (magnitude > magnitudeThreshold &&
          z.abs() > zSpikeThreshold &&
          jerk > jerkThreshold) {

        _lastDetection = now;
        onPotholeDetected();
      }
    });
  }

  void stopListening() {
    _subscription?.cancel();
  }
}
