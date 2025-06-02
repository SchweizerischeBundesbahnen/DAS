import 'dart:async';

import 'package:fimber/fimber.dart';
import 'package:geolocator/geolocator.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:warnapp/src/algorithmus/algorithmus_16.dart';
import 'package:warnapp/src/algorithmus/algorithmus_16_properties.dart';
import 'package:warnapp/src/warnapp_listener.dart';
import 'package:warnapp/src/warnapp_service.dart';

class WarnappServiceImpl implements WarnappService {
  WarnappServiceImpl({this.samplingPeriod = const Duration(microseconds: 16666)}); // 60 hz

  final Duration samplingPeriod;
  final List<WarnappListener> _listeners = [];
  late Algorithmus16 algorithmus;
  _MotionDataContainer _motionDataContainer = _MotionDataContainer();
  bool _enabled = false;
  bool _lastHalt = false;
  int _updatedCount = 0;
  int _gyroUpdateCount = 0;
  int _accelerometerUpdateCount = 0;
  int _locationUpdateCount = 0;

  StreamSubscription? _gyroSubscription;
  StreamSubscription? _accelerometerSubscription;
  StreamSubscription? _locationSubscription;

  void _initialize() {
    algorithmus = Algorithmus16(properties: Algorithmus16Properties.defaultProperties());
    _updatedCount = 0;
    _gyroUpdateCount = 0;
    _accelerometerUpdateCount = 0;

    _gyroSubscription?.cancel();
    _gyroSubscription = gyroscopeEventStream(samplingPeriod: samplingPeriod).listen((event) {
      Fimber.d('gyro event');
      _motionDataContainer.gyroscopeEvent = event;
      _gyroUpdateCount++;
      _handleMotionDateUpdate();
    }, onError: (error) {
      Fimber.e('Error listening to gyro stream', ex: error);
    }, cancelOnError: true);

    _accelerometerSubscription?.cancel();
    _accelerometerSubscription = accelerometerEventStream(samplingPeriod: samplingPeriod).listen((event) {
      Fimber.d('accelerometer event');
      _motionDataContainer.accelerometerEvent = event;
      _accelerometerUpdateCount++;
      _handleMotionDateUpdate();
    }, onError: (error) {
      Fimber.e('Error listening to accelerometer stream', ex: error);
    }, cancelOnError: true);

    _initializeLocation();
  }

  void _initializeLocation() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      Fimber.e('Location service is disabled');
      return;
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        Fimber.e('Location permissions are denied');
        return;
      }
    } else if (permission == LocationPermission.deniedForever) {
      Fimber.e('Location permissions are permanently denied, we cannot request permissions.');
      return;
    }

    Fimber.d('Listening to position updates...');
    _locationSubscription?.cancel();
    _locationSubscription = Geolocator.getPositionStream().listen((Position? position) {
      _motionDataContainer.position = position;
      _locationUpdateCount++;
    });
  }

  void _handleMotionDateUpdate() {
    if (_motionDataContainer.isComplete) {
      final motionData = _motionDataContainer;
      _motionDataContainer = _MotionDataContainer();

      final speed = _motionDataContainer.position?.speed ?? 0.0;
      final timestampSpeed = _motionDataContainer.position?.timestamp.millisecondsSinceEpoch.toDouble() ?? 0.0;
      final latitude = _motionDataContainer.position?.latitude ?? 0.0;
      final longitude = _motionDataContainer.position?.longitude ?? 0.0;
      final horizontalAccuracy = _motionDataContainer.position?.accuracy ?? 0.0;

      final abfahrtDetected = algorithmus.updateWithAcceleration(
          motionData.accelerometerEvent!.x,
          motionData.accelerometerEvent!.y,
          motionData.accelerometerEvent!.z,
          motionData.gyroscopeEvent!.x,
          motionData.gyroscopeEvent!.y,
          motionData.gyroscopeEvent!.z,
          false,
          speed,
          timestampSpeed,
          latitude,
          longitude,
          horizontalAccuracy);

      final isHalt = algorithmus.isHalt;
      if (isHalt != _lastHalt) {
        Fimber.d('Halt state changed to $isHalt');
        _lastHalt = isHalt;
      }

      if (abfahrtDetected) {
        _notifyAbfahrt();
      } else if (isHalt) {
        _notifyHalt();
      }

      if (++_updatedCount % 60 == 0) {
        Fimber.d(
            'Processed $_updatedCount motion updates (gyro=$_gyroUpdateCount, acceleromater=$_accelerometerUpdateCount, location=$_locationUpdateCount)...');
      }
    }
  }

  void _notifyHalt() {
    for (final listener in _listeners) {
      listener.onHaltDetected();
    }
  }

  void _notifyAbfahrt() {
    Fimber.d('Abfahrt detected...');
    for (final listener in _listeners) {
      listener.onAbfahrtDetected();
    }
  }

  @override
  bool get isEnabled => _enabled;

  @override
  void disable() {
    _enabled = false;
    _gyroSubscription?.cancel();
    _accelerometerSubscription?.cancel();
  }

  @override
  void enable() {
    if (!_enabled) {
      _initialize();
      _enabled = true;
    }
  }

  @override
  void addListener(WarnappListener listener) {
    _listeners.add(listener);
  }

  @override
  void removeListener(WarnappListener listener) {
    _listeners.remove(listener);
  }
}

class _MotionDataContainer {
  GyroscopeEvent? gyroscopeEvent;
  AccelerometerEvent? accelerometerEvent;
  Position? position;

  bool get isComplete => gyroscopeEvent != null && accelerometerEvent != null;
}
