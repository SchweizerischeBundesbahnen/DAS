import 'package:fimber/fimber.dart';
import 'package:warnapp/src/algorithmus/algorithmus_16.dart';
import 'package:warnapp/src/algorithmus/algorithmus_16_properties.dart';
import 'package:warnapp/src/data/motion_data.dart';
import 'package:warnapp/src/motion_data_listener.dart';
import 'package:warnapp/src/motion_data_provider.dart';
import 'package:warnapp/src/warnapp_listener.dart';
import 'package:warnapp/src/warnapp_service.dart';

class WarnappServiceImpl implements WarnappService, MotionDataListener {
  WarnappServiceImpl({required this.motionDataProvider});

  final MotionDataProvider motionDataProvider;
  final List<WarnappListener> _listeners = [];
  late Algorithmus16 algorithmus;

  bool _enabled = false;
  bool _lastHalt = false;
  int _updatedCount = 0;

  var _lastCount = 0;
  late DateTime _nextFrequencyCheck;

  void _initialize() {
    algorithmus = Algorithmus16(properties: Algorithmus16Properties.defaultProperties());
    _updatedCount = 0;

    _lastCount = 0;
    _nextFrequencyCheck = DateTime.now().add(Duration(seconds: 1));
  }

  @override
  void onMotionData(MotionData motionData) {
    if (motionData.isComplete) {
      final speed = motionData.position?.speed ?? 0.0;
      final timestampSpeed = motionData.position?.timestamp.millisecondsSinceEpoch.toDouble() ?? 0.0;
      final latitude = motionData.position?.latitude ?? 0.0;
      final longitude = motionData.position?.longitude ?? 0.0;
      final horizontalAccuracy = motionData.position?.accuracy ?? 0.0;

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

      _updatedCount++;
      _updateAndLogFrequency();
    }
  }

  void _updateAndLogFrequency() {
    final now = DateTime.now();
    if (_nextFrequencyCheck.isBefore(now)) {
      Fimber.d('Processed $_updatedCount motion updates... (${_updatedCount - _lastCount} hz)');
      _lastCount = _updatedCount;
      _nextFrequencyCheck = now.add(Duration(seconds: 1));
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
    motionDataProvider.stop();
    _enabled = false;
  }

  @override
  void enable() {
    if (!_enabled) {
      _initialize();
      motionDataProvider.start(this);
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
