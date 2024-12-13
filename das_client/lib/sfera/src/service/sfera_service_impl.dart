import 'dart:async';
import 'dart:core';

import 'package:das_client/auth/authentication_component.dart';
import 'package:das_client/model/journey/journey.dart';
import 'package:das_client/mqtt/mqtt_component.dart';
import 'package:das_client/sfera/sfera_component.dart';
import 'package:das_client/sfera/src/mapper/sfera_model_mapper.dart';
import 'package:das_client/sfera/src/model/enums/das_driving_mode.dart';
import 'package:das_client/sfera/src/model/journey_profile.dart';
import 'package:das_client/sfera/src/model/segment_profile.dart';
import 'package:das_client/sfera/src/model/sfera_g2b_reply_message.dart';
import 'package:das_client/sfera/src/model/train_characteristics.dart';
import 'package:das_client/sfera/src/service/handler/journey_profile_reply_handler.dart';
import 'package:das_client/sfera/src/service/handler/segment_profile_reply_handler.dart';
import 'package:das_client/sfera/src/service/handler/sfera_message_handler.dart';
import 'package:das_client/sfera/src/service/task/handshake_task.dart';
import 'package:das_client/sfera/src/service/task/request_journey_profile_task.dart';
import 'package:das_client/sfera/src/service/task/request_segment_profiles_task.dart';
import 'package:das_client/sfera/src/service/task/request_train_characteristics_task.dart';
import 'package:das_client/sfera/src/service/task/sfera_task.dart';
import 'package:das_client/util/error_code.dart';
import 'package:fimber/fimber.dart';
import 'package:rxdart/rxdart.dart';

class SferaServiceImpl implements SferaService {
  final MqttService _mqttService;
  final SferaRepository _sferaRepository;
  final Authenticator _authenticator;

  StreamSubscription? _mqttStreamSubscription;
  final List<SferaMessageHandler> _messageHandlers = [];

  final _stateSubject = BehaviorSubject.seeded(SferaServiceState.disconnected);

  @override
  Stream<SferaServiceState> get stateStream => _stateSubject.stream;
  final _journeyProfileSubject = BehaviorSubject<Journey?>.seeded(null);

  @override
  Stream<Journey?> get journeyStream => _journeyProfileSubject.stream;

  OtnId? _otnId;
  JourneyProfile? _journeyProfile;
  final List<SegmentProfile> _segmentProfiles = [];
  final List<TrainCharacteristics> _trainCharacteristics = [];

  @override
  ErrorCode? lastErrorCode;

  SferaServiceImpl(
      {required MqttService mqttService,
      required SferaRepository sferaRepository,
      required Authenticator authenticator})
      : _mqttService = mqttService,
        _sferaRepository = sferaRepository,
        _authenticator = authenticator {
    _init();
  }

  void _init() {
    _mqttStreamSubscription = _mqttService.messageStream.listen((message) async {
      final sferaG2bReplyMessage = SferaReplyParser.parse<SferaG2bReplyMessage>(message);
      if (!sferaG2bReplyMessage.validate()) {
        Fimber.w('Validation failed for MQTT response $message');
        return;
      }

      var handled = false;
      for (final handler in List.from(_messageHandlers)) {
        handled |= await handler.handleMessage(sferaG2bReplyMessage);
      }

      if (!handled) {
        Fimber.w('Could not handle sfera message $message');
      }
    });
  }

  @override
  Future<void> connect(OtnId otnId) async {
    Fimber.i('Starting new connection for $otnId');
    _otnId = otnId;
    _messageHandlers.clear();
    lastErrorCode = null;
    _stateSubject.add(SferaServiceState.connecting);

    if (await _mqttService.connect(
        otnId.company, SferaService.sferaTrain(otnId.operationalTrainNumber, otnId.startDate))) {
      _stateSubject.add(SferaServiceState.handshaking);
      final user = await _authenticator.user();
      final drivingMode = user.roles.contains(Role.driver) ? DasDrivingMode.dasNotConnected : DasDrivingMode.readOnly;

      final handshakeTask = HandshakeTask(mqttService: _mqttService, otnId: otnId, dasDrivingMode: drivingMode);
      _messageHandlers.add(handshakeTask);
      handshakeTask.execute(onTaskCompleted, onTaskFailed);
    } else {
      _otnId = null;
      lastErrorCode = ErrorCode.connectionFailed;
      _stateSubject.add(SferaServiceState.disconnected);
    }
  }

  void onTaskCompleted(SferaTask task, dynamic data) async {
    _messageHandlers.remove(task);
    Fimber.i('Task $task completed');
    if (task is HandshakeTask) {
      _stateSubject.add(SferaServiceState.loadingJourney);
      final requestJourneyTask =
          RequestJourneyProfileTask(mqttService: _mqttService, sferaRepository: _sferaRepository, otnId: _otnId!);
      _messageHandlers.add(requestJourneyTask);
      requestJourneyTask.execute(onTaskCompleted, onTaskFailed);
    } else if (task is RequestJourneyProfileTask) {
      _stateSubject.add(SferaServiceState.loadingAdditionalData);
      final requestSegmentProfilesTask = RequestSegmentProfilesTask(
          mqttService: _mqttService, sferaRepository: _sferaRepository, otnId: _otnId!, journeyProfile: data);
      final requestTrainCharacteristicsTask = RequestTrainCharacteristicsTask(
          mqttService: _mqttService, sferaRepository: _sferaRepository, otnId: _otnId!, journeyProfile: data);
      _journeyProfile = data;
      _messageHandlers.add(requestSegmentProfilesTask);
      _messageHandlers.add(requestTrainCharacteristicsTask);
      requestSegmentProfilesTask.execute(onTaskCompleted, onTaskFailed);
      requestTrainCharacteristicsTask.execute(onTaskCompleted, onTaskFailed);
    }

    if (_stateSubject.value == SferaServiceState.loadingAdditionalData && _allTaskedCompleted()) {
      _addMessageHandlers();
      await _refreshSegmentProfiles();
      await _refreshTrainCharacteristics();
      final success = _updateJourney();
      if (success) {
        _stateSubject.add(SferaServiceState.connected);
      } else {
        lastErrorCode = ErrorCode.sferaSpInvalid;
        disconnect();
      }
    }
  }

  bool _allTaskedCompleted() {
    return _messageHandlers.whereType<SferaTask>().isEmpty;
  }

  Future<void> _refreshSegmentProfiles() async {
    if (_journeyProfile != null) {
      _segmentProfiles.clear();

      for (final element in _journeyProfile!.segmentProfilesLists) {
        final segmentProfileEntity =
            await _sferaRepository.findSegmentProfile(element.spId, element.versionMajor, element.versionMinor);
        final segmentProfile = segmentProfileEntity?.toDomain();
        if (segmentProfile != null && segmentProfile.validate()) {
          _segmentProfiles.add(segmentProfile);
        } else {
          Fimber.w('Could not find and validate segment profile for ${element.spId}');
        }
      }
    }
  }

  Future<void> _refreshTrainCharacteristics() async {
    if (_journeyProfile != null) {
      _trainCharacteristics.clear();

      for (final element in _journeyProfile!.trainCharactericsRefSet) {
        final trainCharactericsEntity =
        await _sferaRepository.findTrainCharacteristics(element.tcId, element.versionMajor, element.versionMinor);
        final trainCharacterics = trainCharactericsEntity?.toDomain();
        if (trainCharacterics != null && trainCharacterics.validate()) {
          _trainCharacteristics.add(trainCharacterics);
        } else {
          Fimber.w('Could not find and validate $element');
        }
      }
    }
  }

  bool _updateJourney() {
    if (_journeyProfile != null && _segmentProfiles.isNotEmpty) {
      Fimber.i('Updating journey stream...');
      final newJourney = SferaModelMapper.mapToJourney(_journeyProfile!, _segmentProfiles, _trainCharacteristics);
      if (newJourney.valid) {
        _journeyProfileSubject.add(newJourney);
        Fimber.i('Journey updates successfully.');
        return true;
      } else {
        Fimber.w('Failed to update journey as it is not valid');
      }
    }
    return false;
  }

  void _addMessageHandlers() {
    _messageHandlers.add(JourneyProfileReplyHandler(_sferaRepository));
    _messageHandlers.add(SegmentProfileReplyHandler(_sferaRepository));
  }

  void onTaskFailed(SferaTask task, ErrorCode errorCode) {
    _messageHandlers.remove(task);
    lastErrorCode = errorCode;
    Fimber.e('Task $task failed with error code $errorCode');
    if (task is HandshakeTask || task is RequestJourneyProfileTask || task is RequestSegmentProfilesTask) {
      disconnect();
    }
  }

  @override
  void disconnect() {
    _mqttService.disconnect();
    _stateSubject.add(SferaServiceState.disconnected);
  }

  void dispose() {
    _mqttStreamSubscription?.cancel();
    _mqttStreamSubscription = null;
  }
}
