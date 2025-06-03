import 'package:geolocator/geolocator.dart';
import 'package:sensors_plus/sensors_plus.dart';

class MotionData {
  GyroscopeEvent? gyroscopeEvent;
  AccelerometerEvent? accelerometerEvent;
  Position? position;

  bool get isComplete => gyroscopeEvent != null && accelerometerEvent != null;
}
