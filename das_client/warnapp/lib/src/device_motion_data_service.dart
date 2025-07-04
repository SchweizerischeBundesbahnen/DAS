import 'dart:async';

import 'package:geolocator/geolocator.dart';
import 'package:logging/logging.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:warnapp/src/data/motion_data.dart';
import 'package:warnapp/src/motion_data_listener.dart';
import 'package:warnapp/src/motion_data_service.dart';

final _log = Logger('DeviceMotionDataService');

class DeviceMotionDataService implements MotionDataService {
  DeviceMotionDataService({this.samplingPeriod = const Duration(microseconds: 16666)}); // 60 hz

  final Duration samplingPeriod;
  MotionDataListener? _motionDataListener;
  MotionData _motionData = MotionData();

  StreamSubscription? _gyroSubscription;
  StreamSubscription? _accelerometerSubscription;
  StreamSubscription? _locationSubscription;

  @override
  void start(MotionDataListener listener) {
    _motionDataListener = listener;
    _motionData = MotionData();

    _gyroSubscription?.cancel();
    _gyroSubscription = gyroscopeEventStream(samplingPeriod: samplingPeriod).listen(
      (event) {
        _motionData.gyroscopeEvent = event;
        _handleNotify();
      },
      onError: (error) {
        _log.severe('Error listening to gyro stream', error);
      },
      cancelOnError: true,
    );

    _accelerometerSubscription?.cancel();
    _accelerometerSubscription = accelerometerEventStream(samplingPeriod: samplingPeriod).listen(
      (event) {
        _motionData.accelerometerEvent = event;
        _handleNotify();
      },
      onError: (error) {
        _log.severe('Error listening to accelerometer stream', error);
      },
      cancelOnError: true,
    );

    _initializeLocation();
  }

  void _initializeLocation() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      _log.severe('Location service is disabled');
      return;
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        _log.severe('Location permissions are denied');
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      _log.severe('Location permissions are permanently denied, we cannot request permissions.');
      return;
    }

    _log.fine('Listening to position updates...');
    _locationSubscription?.cancel();
    _locationSubscription = Geolocator.getPositionStream().listen((Position? position) {
      _motionData.position = position;
    });
  }

  void _handleNotify() {
    if (_motionData.isComplete) {
      _motionDataListener?.onMotionData(_motionData);
      _motionData = MotionData();
    }
  }

  @override
  void stop() {
    _motionDataListener = null;
    _gyroSubscription?.cancel();
    _gyroSubscription = null;
    _accelerometerSubscription?.cancel();
    _accelerometerSubscription = null;
    _locationSubscription?.cancel();
    _locationSubscription = null;
  }
}
