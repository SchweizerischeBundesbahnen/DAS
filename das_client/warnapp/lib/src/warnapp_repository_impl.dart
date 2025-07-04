import 'dart:io';

import 'package:logging/logging.dart';
import 'package:path_provider/path_provider.dart';
import 'package:rxdart/rxdart.dart';
import 'package:warnapp/src/algorithmus/abfahrt_detection_algorithmus.dart';
import 'package:warnapp/src/algorithmus/abfahrt_detection_algorithmus_properties.dart';
import 'package:warnapp/src/data/motion_data.dart';
import 'package:warnapp/src/motion_data_listener.dart';
import 'package:warnapp/src/motion_data_service.dart';
import 'package:warnapp/src/warnapp_repository.dart';

final _log = Logger('WarnappRepositoryImpl');

class WarnappRepositoryImpl implements WarnappRepository, MotionDataListener {
  WarnappRepositoryImpl({required this.motionDataService}) {
    _createLogDirectory();
  }

  final MotionDataService motionDataService;
  late AbfahrtDetectionAlgorithmus algorithmus;

  final _rxAbfahrt = PublishSubject<void>();
  final _rxHalt = PublishSubject<void>();

  @override
  Stream<void> get abfahrtEventStream => _rxAbfahrt.stream;

  @override
  Stream<void> get haltEventStream => _rxHalt.stream;

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
      _log.fine('Halt state changed to $isHalt');
      _lastHalt = isHalt;
    }

    if (abfahrtDetected) {
      _log.fine('Abfahrt detected...');
      _rxAbfahrt.add(null);
    } else if (isHalt) {
      _rxHalt.add(null);
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
      _log.fine('Processed $_updatedCount motion updates... (${_updatedCount - _lastCount} hz)');
      _lastCount = _updatedCount;
      _nextFrequencyCheck = now.add(Duration(seconds: 1));
    }
  }

  @override
  bool get isEnabled => _enabled;

  @override
  void disable() {
    motionDataService.stop();
    _enabled = false;
  }

  @override
  void enable() {
    if (!_enabled) {
      _initialize();
      motionDataService.start(this);
      _enabled = true;
    }
  }
}
