import 'package:geolocator/geolocator.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:warnapp/src/data/motion_data.dart';
import 'package:warnapp/src/motion_data_listener.dart';
import 'package:warnapp/src/motion_data_provider.dart';

class MockMotionDataProvider implements MotionDataProvider {
  MockMotionDataProvider({String? motionData, this.samplingPeriod}) {
    _parseMotionData(motionData);
  }

  MotionDataListener? _motionDataListener;
  final List<MotionData> _motionData = [];
  final Duration? samplingPeriod;
  var _isReplayingEvents = false;

  bool get isReplayingEvents => _isReplayingEvents;

  void _parseMotionData(String? motionDataString) {
    if (motionDataString == null) {
      return;
    }
    _motionData.clear();

    final rows = motionDataString.split('\n');
    for (final row in rows.skip(1)) {
      final data = row.split(',');
      if (data.length < 16) {
        continue;
      }

      final timestamp = DateTime.fromMillisecondsSinceEpoch(double.parse(data[0]).toInt());
      final motionData = MotionData();
      motionData.gyroscopeEvent =
          GyroscopeEvent(double.parse(data[2]), double.parse(data[3]), double.parse(data[4]), timestamp);
      motionData.accelerometerEvent =
          AccelerometerEvent(double.parse(data[5]), double.parse(data[6]), double.parse(data[7]), timestamp);

      if (data[10].trim().isNotEmpty) {
        final locationTimestamp = DateTime.fromMillisecondsSinceEpoch(double.parse(data[10]).toInt());
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

  void updateMotionData(String motionData) {
    _parseMotionData(motionData);
  }

  @override
  void start(MotionDataListener listener) {
    _motionDataListener = listener;
    _notifyEvents();
  }

  void _notifyEvents() async {
    _isReplayingEvents = true;
    for (final motionData in _motionData) {
      if (samplingPeriod != null) {
        await Future.delayed(samplingPeriod!);
      }
      _motionDataListener?.onMotionData(motionData);
    }

    _isReplayingEvents = false;
  }

  @override
  void stop() {
    _motionDataListener = null;
  }
}
