import 'dart:async';
import 'dart:core';

import 'package:das_client/auth/authentication_component.dart';
import 'package:das_client/model/journey/journey.dart';
import 'package:das_client/mqtt/mqtt_component.dart';
import 'package:das_client/sfera/sfera_component.dart';
import 'package:das_client/sfera/src/mapper/sfera_model_mapper.dart';
import 'package:das_client/sfera/src/model/enums/das_driving_mode.dart';
import 'package:das_client/sfera/src/model/journey_profile.dart';
import 'package:das_client/sfera/src/model/related_train_information.dart';
import 'package:das_client/sfera/src/model/segment_profile.dart';
import 'package:das_client/sfera/src/model/sfera_g2b_event_message.dart';
import 'package:das_client/sfera/src/model/sfera_g2b_reply_message.dart';
import 'package:das_client/sfera/src/model/sfera_xml_element.dart';
import 'package:das_client/sfera/src/model/train_characteristics.dart';
import 'package:das_client/sfera/src/service/event/journey_profile_event_handler.dart';
import 'package:das_client/sfera/src/service/event/related_train_information_event_handler.dart';
import 'package:das_client/sfera/src/service/event/sfera_event_message_handler.dart';
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
  final List<SferaTask> _tasks = [];
  final List<SferaEventMessageHandler> _eventMessageHandler = [];

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
  RelatedTrainInformation? _relatedTrainInformation;

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
    _addEventMessageHandlers();
    _mqttStreamSubscription = _mqttService.messageStream.listen((xmlMessage) async {
      final message = SferaReplyParser.parse<SferaXmlElement>(xmlMessage);
      if (!message.validate()) {
        Fimber.w('Validation failed for MQTT response $xmlMessage');
        return;
      }

      if (message is SferaG2bReplyMessage) {
        var handled = false;
        for (final handler in List.from(_tasks)) {
          handled |= await handler.handleMessage(message);
        }

        if (!handled) {
          Fimber.w('Could not handle sfera reply message $xmlMessage');
        }
      } else if (message is SferaG2bEventMessage) {
        var handled = false;
        for (final handler in List.from(_eventMessageHandler)) {
          handled |= await handler.handleMessage(message);
        }

        if (!handled) {
          Fimber.w('Could not handle sfera event message $xmlMessage');
        }
      }
    });
  }

  @override
  Future<void> connect(OtnId otnId) async {
    Fimber.i('Starting new connection for $otnId');
    _otnId = otnId;
    _tasks.clear();
    lastErrorCode = null;
    _stateSubject.add(SferaServiceState.connecting);

    if (await _mqttService.connect(
        otnId.company, SferaService.sferaTrain(otnId.operationalTrainNumber, otnId.startDate))) {
      _stateSubject.add(SferaServiceState.handshaking);
      final user = await _authenticator.user();
      final drivingMode = user.roles.contains(Role.driver) ? DasDrivingMode.dasNotConnected : DasDrivingMode.readOnly;

      final handshakeTask = HandshakeTask(mqttService: _mqttService, otnId: otnId, dasDrivingMode: drivingMode);
      _tasks.add(handshakeTask);
      handshakeTask.execute(onTaskCompleted, onTaskFailed);
    } else {
      _otnId = null;
      lastErrorCode = ErrorCode.connectionFailed;
      _stateSubject.add(SferaServiceState.disconnected);
    }
  }

  void onTaskCompleted(SferaTask task, dynamic data) async {
    _tasks.remove(task);
    Fimber.i('Task $task completed');
    if (task is HandshakeTask) {
      _stateSubject.add(SferaServiceState.loadingJourney);
      final requestJourneyTask =
          RequestJourneyProfileTask(mqttService: _mqttService, sferaRepository: _sferaRepository, otnId: _otnId!);
      _tasks.add(requestJourneyTask);
      requestJourneyTask.execute(onTaskCompleted, onTaskFailed);
    } else if (task is RequestJourneyProfileTask) {
      _stateSubject.add(SferaServiceState.loadingAdditionalData);
      final dataList = data as List;
      _journeyProfile = dataList.whereType<JourneyProfile>().first;
      _relatedTrainInformation = dataList.whereType<RelatedTrainInformation>().firstOrNull;
      _startSegmentProfileAndTCTask();
    }

    if (_allTasksCompleted()) {
      switch (_stateSubject.value) {
        case SferaServiceState.loadingAdditionalData:
          await _refreshSegmentProfiles();
          await _refreshTrainCharacteristics();
          final success = _updateJourney();
          if (success) {
            _stateSubject.add(SferaServiceState.connected);
          } else {
            disconnect();
          }
          break;
        case SferaServiceState.connected:
          await _refreshSegmentProfiles();
          await _refreshTrainCharacteristics();
          _updateJourney();
        default:
      }
    }
  }

  void _startSegmentProfileAndTCTask() {
    final requestSegmentProfilesTask = RequestSegmentProfilesTask(
        mqttService: _mqttService, sferaRepository: _sferaRepository, otnId: _otnId!, journeyProfile: _journeyProfile!);
    final requestTrainCharacteristicsTask = RequestTrainCharacteristicsTask(
        mqttService: _mqttService, sferaRepository: _sferaRepository, otnId: _otnId!, journeyProfile: _journeyProfile!);
    _tasks.add(requestSegmentProfilesTask);
    _tasks.add(requestTrainCharacteristicsTask);
    requestSegmentProfilesTask.execute(onTaskCompleted, onTaskFailed);
    requestTrainCharacteristicsTask.execute(onTaskCompleted, onTaskFailed);
  }

  bool _allTasksCompleted() {
    return _tasks.whereType<SferaTask>().isEmpty;
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
      final newJourney = SferaModelMapper.mapToJourney(
          journeyProfile: _journeyProfile!,
          segmentProfiles: _segmentProfiles,
          trainCharacteristics: _trainCharacteristics,
          relatedTrainInformation: _relatedTrainInformation);
      if (newJourney.valid) {
        _journeyProfileSubject.add(newJourney);
        Fimber.i('Journey updates successfully.');
        return true;
      } else {
        Fimber.w('Failed to update journey as it is not valid');
        lastErrorCode = ErrorCode.sferaInvalid;
      }
    }
    return false;
  }

  void _addEventMessageHandlers() {
    _eventMessageHandler.add(JourneyProfileEventHandler(onJourneyProfileUpdated, _sferaRepository));
    _eventMessageHandler.add(RelatedTrainInformationEventHandler(onRelatedTrainInformationUpdated));
  }

  void onJourneyProfileUpdated(SferaEventMessageHandler handler, JourneyProfile data) async {
    _journeyProfile = data;
    _startSegmentProfileAndTCTask();
  }

  void onRelatedTrainInformationUpdated(SferaEventMessageHandler handler, RelatedTrainInformation data) async {
    _relatedTrainInformation = data;
    _updateJourney();
  }

  void onTaskFailed(SferaTask task, ErrorCode errorCode) {
    _tasks.remove(task);
    lastErrorCode = errorCode;
    Fimber.e('Task $task failed with error code $errorCode');
    if (_stateSubject.value != SferaServiceState.connected) {
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
