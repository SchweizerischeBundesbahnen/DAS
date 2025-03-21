import 'dart:async';
import 'dart:core';

import 'package:das_client/auth/authentication_component.dart';
import 'package:das_client/model/journey/journey.dart';
import 'package:das_client/model/journey/ux_testing.dart';
import 'package:das_client/mqtt/mqtt_component.dart';
import 'package:das_client/sfera/sfera_component.dart';
import 'package:das_client/sfera/src/mapper/sfera_model_mapper.dart';
import 'package:das_client/sfera/src/model/enums/das_driving_mode.dart';
import 'package:das_client/sfera/src/model/journey_profile.dart';
import 'package:das_client/sfera/src/model/network_specific_event.dart';
import 'package:das_client/sfera/src/model/related_train_information.dart';
import 'package:das_client/sfera/src/model/segment_profile.dart';
import 'package:das_client/sfera/src/model/sfera_b2g_event_message.dart';
import 'package:das_client/sfera/src/model/sfera_g2b_event_message.dart';
import 'package:das_client/sfera/src/model/sfera_g2b_reply_message.dart';
import 'package:das_client/sfera/src/model/sfera_xml_element.dart';
import 'package:das_client/sfera/src/model/train_characteristics.dart';
import 'package:das_client/sfera/src/model/ux_testing_nse.dart';
import 'package:das_client/sfera/src/service/remote/event/journey_profile_event_handler.dart';
import 'package:das_client/sfera/src/service/remote/event/network_specific_event_handler.dart';
import 'package:das_client/sfera/src/service/remote/event/related_train_information_event_handler.dart';
import 'package:das_client/sfera/src/service/remote/event/sfera_event_message_handler.dart';
import 'package:das_client/sfera/src/service/remote/task/handshake_task.dart';
import 'package:das_client/sfera/src/service/remote/task/request_journey_profile_task.dart';
import 'package:das_client/sfera/src/service/remote/task/request_segment_profiles_task.dart';
import 'package:das_client/sfera/src/service/remote/task/request_train_characteristics_task.dart';
import 'package:das_client/sfera/src/service/remote/task/sfera_task.dart';
import 'package:das_client/util/error_code.dart';
import 'package:fimber/fimber.dart';
import 'package:rxdart/rxdart.dart';

class SferaServiceImpl implements SferaService {
  SferaServiceImpl({
    required MqttService mqttService,
    required SferaDatabaseRepository sferaDatabaseRepository,
    required Authenticator authenticator,
  })  : _mqttService = mqttService,
        _sferaDatabaseRepository = sferaDatabaseRepository,
        _authenticator = authenticator {
    _init();
  }

  final MqttService _mqttService;
  final SferaDatabaseRepository _sferaDatabaseRepository;
  final Authenticator _authenticator;

  StreamSubscription? _mqttStreamSubscription;
  final List<SferaTask> _tasks = [];
  final List<SferaEventMessageHandler> _eventMessageHandler = [];

  final _stateSubject = BehaviorSubject.seeded(SferaServiceState.disconnected);
  final _journeyProfileSubject = BehaviorSubject<Journey?>.seeded(null);
  final _uxTestingSubject = BehaviorSubject<UxTesting?>.seeded(null);

  @override
  Stream<SferaServiceState> get stateStream => _stateSubject.stream;

  @override
  Stream<Journey?> get journeyStream => _journeyProfileSubject.stream;

  @override
  Stream<UxTesting?> get uxTestingStream => _uxTestingSubject.stream;

  OtnId? _otnId;
  JourneyProfile? _journeyProfile;
  final List<SegmentProfile> _segmentProfiles = [];
  final List<TrainCharacteristics> _trainCharacteristics = [];
  RelatedTrainInformation? _relatedTrainInformation;

  @override
  ErrorCode? lastErrorCode;

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
      final requestJourneyTask = RequestJourneyProfileTask(
          mqttService: _mqttService, sferaDatabaseRepository: _sferaDatabaseRepository, otnId: _otnId!);
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
        mqttService: _mqttService,
        sferaDatabaseRepository: _sferaDatabaseRepository,
        otnId: _otnId!,
        journeyProfile: _journeyProfile!);
    final requestTrainCharacteristicsTask = RequestTrainCharacteristicsTask(
        mqttService: _mqttService,
        sferaDatabaseRepository: _sferaDatabaseRepository,
        otnId: _otnId!,
        journeyProfile: _journeyProfile!);
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

      for (final element in _journeyProfile!.segmentProfileReferences) {
        final segmentProfileEntity =
            await _sferaDatabaseRepository.findSegmentProfile(element.spId, element.versionMajor, element.versionMinor);
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

      for (final element in _journeyProfile!.trainCharacteristicsRefSet) {
        final trainCharacteristicsEntity = await _sferaDatabaseRepository.findTrainCharacteristics(
            element.tcId, element.versionMajor, element.versionMinor);
        final trainCharacteristics = trainCharacteristicsEntity?.toDomain();
        if (trainCharacteristics != null && trainCharacteristics.validate()) {
          _trainCharacteristics.add(trainCharacteristics);
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
        relatedTrainInformation: _relatedTrainInformation,
        lastJourney: _journeyProfileSubject.value,
      );
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
    _eventMessageHandler.add(JourneyProfileEventHandler(onJourneyProfileUpdated, _sferaDatabaseRepository));
    _eventMessageHandler.add(RelatedTrainInformationEventHandler(onRelatedTrainInformationUpdated));
    _eventMessageHandler.add(NetworkSpecificEventHandler(onNetworkSpecificEvent));
  }

  void onJourneyProfileUpdated(SferaEventMessageHandler handler, JourneyProfile data) async {
    _journeyProfile = data;
    _startSegmentProfileAndTCTask();
  }

  void onRelatedTrainInformationUpdated(SferaEventMessageHandler handler, RelatedTrainInformation data) async {
    _relatedTrainInformation = data;
    _updateJourney();
  }

  void onNetworkSpecificEvent(SferaEventMessageHandler handler, NetworkSpecificEvent data) async {
    if (data is UxTestingNse) {
      if (data.koa != null) {
        final uxTesting = UxTesting(name: data.koa!.name, value: data.koa!.nspValue);
        _uxTestingSubject.add(uxTesting);
      }

      if (data.warn != null) {
        final uxTesting = UxTesting(name: data.warn!.name, value: data.warn!.nspValue);
        _uxTestingSubject.add(uxTesting);
      }
    }
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
  Future<void> disconnect() async {
    final otnId = _otnId;
    if (_stateSubject.value == SferaServiceState.connected && otnId != null) {
      Fimber.i('Sending session termination request for $otnId...');
      final header = await SferaService.messageHeader(sender: otnId.company);
      final sessionTerminationMessage = SferaB2gEventMessage.createSessionTermination(messageHeader: header);
      _mqttService.publishMessage(otnId.company, SferaService.sferaTrain(otnId.operationalTrainNumber, otnId.startDate),
          sessionTerminationMessage.buildDocument().toString());
    }

    _mqttService.disconnect();
    _stateSubject.add(SferaServiceState.disconnected);
  }

  void dispose() {
    _mqttStreamSubscription?.cancel();
    _mqttStreamSubscription = null;
  }
}
