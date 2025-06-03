import 'package:geolocator/geolocator.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:warnapp/src/data/motion_data.dart';
import 'package:warnapp/src/motion_data_listener.dart';
import 'package:warnapp/src/motion_data_provider.dart';

class MockMotionDataProvider implements MotionDataProvider {
  MockMotionDataProvider({required String motionData}) {
    _parseMotionData(motionData);
  }

  MotionDataListener? _motionDataListener;
  final List<MotionData> _motionData = [];

  void _parseMotionData(String motionDataString) {
    final rows = motionDataString.split('\n');
    for (final row in rows) {
      final data = row.split(',');
      final timestamp = DateTime.fromMillisecondsSinceEpoch(int.parse(data[0]));
      final motionData = MotionData();
      motionData.gyroscopeEvent =
          GyroscopeEvent(double.parse(data[2]), double.parse(data[3]), double.parse(data[4]), timestamp);
      motionData.accelerometerEvent =
          AccelerometerEvent(double.parse(data[5]), double.parse(data[6]), double.parse(data[7]), timestamp);

      if (data[10].trim().isNotEmpty) {
        final locationTimestamp = DateTime.fromMillisecondsSinceEpoch(int.parse(data[10]));
        motionData.position = Position(
            longitude: double.parse(data[11]),
            latitude: double.parse(data[12]),
            timestamp: locationTimestamp,
            accuracy: double.parse(data[13]),
            altitude: 0.0,
            altitudeAccuracy: 0.0,
            heading: 0.0,
            headingAccuracy: 0.0,
            speed: double.parse(data[15]),
            speedAccuracy: 0.0);
      }

      _motionData.add(motionData);
    }
  }

  @override
  void start(MotionDataListener listener) {
    _motionDataListener = listener;
    _notifyEvents();
  }

  void _notifyEvents() async {
    for (final motionData in _motionData) {
      _motionDataListener?.onMotionData(motionData);
    }
  }

  @override
  void stop() {
    _motionDataListener = null;
  }
}
