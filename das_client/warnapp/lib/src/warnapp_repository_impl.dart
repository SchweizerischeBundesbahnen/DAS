import 'dart:io';

import 'package:fimber/fimber.dart';
import 'package:path_provider/path_provider.dart';
import 'package:warnapp/src/algorithmus/abfahrt_detection_algorithmus.dart';
import 'package:warnapp/src/algorithmus/abfahrt_detection_algorithmus_properties.dart';
import 'package:warnapp/src/data/motion_data.dart';
import 'package:warnapp/src/motion_data_listener.dart';
import 'package:warnapp/src/motion_data_service.dart';
import 'package:warnapp/src/warnapp_listener.dart';
import 'package:warnapp/src/warnapp_repository.dart';

class WarnappServiceImpl implements WarnappRepository, MotionDataListener {
  WarnappServiceImpl({required this.motionDataProvider}) {
    _createLogDirectory();
  }

  final MotionDataService motionDataProvider;
  final List<WarnappListener> _listeners = [];
  late AbfahrtDetectionAlgorithmus algorithmus;

  bool _enabled = false;
  bool _lastHalt = false;
  int _updatedCount = 0;

  var _lastCount = 0;
  late DateTime _nextFrequencyCheck;

  static const bool saveMotionDataToFile = false;
  late Directory _logDirectory;
  File? _logFile;

  void _initialize() {
    algorithmus = AbfahrtDetectionAlgorithmus(properties: AbfahrtDetectionAlgorithmusProperties.defaultProperties());
    _updatedCount = 0;

    _lastCount = 0;
    _nextFrequencyCheck = DateTime.now().add(Duration(seconds: 1));

    _logFile = null;
  }

  void _createLogDirectory() async {
    if (saveMotionDataToFile) {
      final appSupportDirectory = await getApplicationSupportDirectory();
      _logDirectory = Directory('${appSupportDirectory.path}/motion_logs/');
      if (!_logDirectory.existsSync()) {
        _logDirectory.createSync(recursive: true);
      }
    }
  }

  @override
  void onMotionData(MotionData motionData) {
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
      horizontalAccuracy,
    );

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

    if (saveMotionDataToFile) {
      _saveToFile(motionData, isHalt);
    }
  }

  void _saveToFile(MotionData motionData, bool isHalt) {
    if (_logFile == null) {
      _logFile = File('${_logDirectory.path}/motion_data_log_${DateTime.now().millisecondsSinceEpoch}.txt');
      _logFile?.writeAsStringSync(
        'TS_EPOCH,updatesCount,ROT_X,ROT_Y,ROT_Z,ACC_X,ACC_Y,ACC_Z,TOUCH,HALT,GPS_TIME,GPS_LAT,GPS_LONG,GPS_HACC,GPS_VACC,GPS_SPEED\n',
      );
    }
    final logEntry =
        '${motionData.gyroscopeEvent?.timestamp.millisecondsSinceEpoch},'
        '$_updatedCount,'
        '${motionData.gyroscopeEvent?.x},'
        '${motionData.gyroscopeEvent?.y},'
        '${motionData.gyroscopeEvent?.z},'
        '${motionData.accelerometerEvent?.x},'
        '${motionData.accelerometerEvent?.y},'
        '${motionData.accelerometerEvent?.z},'
        '0,'
        '${isHalt ? '1' : '0'},'
        '${motionData.position?.timestamp.millisecondsSinceEpoch ?? ''},'
        '${motionData.position?.latitude ?? ''},'
        '${motionData.position?.longitude ?? ''},'
        '${motionData.position?.accuracy ?? ''},'
        '${motionData.position?.accuracy ?? ''},'
        '${motionData.position?.speed ?? ''}\n';
    _logFile!.writeAsStringSync(logEntry, mode: FileMode.append);
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
