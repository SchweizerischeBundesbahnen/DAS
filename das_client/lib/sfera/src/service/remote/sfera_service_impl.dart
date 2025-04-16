import 'dart:async';
import 'dart:core';
import 'dart:ui';

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
    _initialize();
  }

  final MqttService _mqttService;
  final SferaDatabaseRepository _sferaDatabaseRepository;
  final Authenticator _authenticator;

  StreamSubscription? _mqttStreamSubscription;
  final List<SferaTask> _tasks = [];
  final List<SferaEventMessageHandler> _eventMessageHandlers = [];

  final _stateSubject = BehaviorSubject.seeded(SferaServiceState.disconnected);
  final _journeyProfileSubject = BehaviorSubject<Journey?>.seeded(null);
  final _uxTestingSubject = BehaviorSubject<UxTesting?>.seeded(null);

  @override
  Stream<SferaServiceState> get stateStream => _stateSubject.distinct();

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

  /// Connects to SFERA broker and initiate Handshake with [HandshakeTask].
  /// Other tasks like loading SP, JPs and TCs are triggered on completion.
  @override
  Future<void> connect(OtnId otnId) async {
    Fimber.i('Starting new connection for $otnId');
    _otnId = otnId;
    _tasks.clear();
    lastErrorCode = null;
    _stateSubject.add(SferaServiceState.connecting);

    final sferaTrain = SferaService.sferaTrain(otnId.operationalTrainNumber, otnId.startDate);
    final isConnected = await _mqttService.connect(otnId.company, sferaTrain);
    if (isConnected) {
      await _initiateHandshake(otnId);
    } else {
      _otnId = null;
      lastErrorCode = ErrorCode.connectionFailed;
      _stateSubject.add(SferaServiceState.disconnected);
    }
  }

  /// Sends [SessionTermination] and disconnects from SFERA broker.
  ///
  /// Disconnect is either called by the user or when one of the [SferaTask] fails and no journey was loaded yet - i.e. the service is not in the [SferaServiceState.connected].
  @override
  Future<void> disconnect() async {
    final otnId = _otnId;
    if (_stateSubject.value == SferaServiceState.connected && otnId != null) {
      Fimber.i('Sending session termination request for $otnId...');
      final header = await SferaService.messageHeader(sender: otnId.company);
      final sessionTerminationMessage = SferaB2gEventMessage.createSessionTermination(messageHeader: header);
      final sferaTrain = SferaService.sferaTrain(otnId.operationalTrainNumber, otnId.startDate);
      _mqttService.publishMessage(otnId.company, sferaTrain, sessionTerminationMessage.buildDocument().toString());
    }

    _mqttService.disconnect();
    _stateSubject.add(SferaServiceState.disconnected);
  }

  void _initialize() {
    _addEventMessageHandlers();
    _mqttStreamSubscription = _mqttService.messageStream.listen(_handleMqttMessage);
  }

  void _handleMqttMessage(String xmlMessage) async {
    final message = SferaReplyParser.parse<SferaXmlElement>(xmlMessage);
    if (!message.validate()) {
      Fimber.w('Validation failed for MQTT response $xmlMessage');
      return;
    }

    if (message is SferaG2bReplyMessage) {
      await _handleReplyMessage(message, xmlMessage);
    } else if (message is SferaG2bEventMessage) {
      await _handleEventMessage(message, xmlMessage);
    }
  }

  Future<void> _handleReplyMessage(SferaG2bReplyMessage message, String xmlMessage) async {
    var handled = false;
    for (final handler in List.from(_tasks)) {
      handled |= await handler.handleMessage(message);
    }

    if (!handled) {
      Fimber.w('Could not handle Sfera reply message $xmlMessage');
    }
  }

  Future<void> _handleEventMessage(SferaG2bEventMessage message, String xmlMessage) async {
    var handled = false;
    for (final handler in List.from(_eventMessageHandlers)) {
      handled |= await handler.handleMessage(message);
    }

    if (!handled) {
      Fimber.w('Could not handle Sfera event message $xmlMessage');
    }
  }

  Future<void> _initiateHandshake(OtnId otnId) async {
    _stateSubject.add(SferaServiceState.handshaking);
    final user = await _authenticator.user();
    final drivingMode = user.roles.contains(Role.driver) ? DasDrivingMode.dasNotConnected : DasDrivingMode.readOnly;

    final handshakeTask = HandshakeTask(mqttService: _mqttService, otnId: otnId, dasDrivingMode: drivingMode);
    _tasks.add(handshakeTask);
    handshakeTask.execute(_onTaskCompleted, _onTaskFailed);
  }

  void _onTaskCompleted(SferaTask task, dynamic data) async {
    _tasks.remove(task);
    Fimber.i('Task $task completed');
    switch (task) {
      case HandshakeTask _:
        await _handleHandshakeTaskCompleted();
      case RequestJourneyProfileTask _:
        await _handleRequestJourneyProfileTaskCompleted(data);
    }

    if (_allTasksCompleted()) {
      switch (_stateSubject.value) {
        case SferaServiceState.loadingAdditionalData:
          await _refreshSegmentProfiles();
          await _refreshTrainCharacteristics();
          _updateJourney(
            onSuccess: () => _stateSubject.add(SferaServiceState.connected),
            onInvalid: () => disconnect(),
          );
          break;
        case SferaServiceState.connected:
          await _refreshSegmentProfiles();
          await _refreshTrainCharacteristics();
          _updateJourney();
          break;
        default:
      }
    }
  }

  Future<void> _handleHandshakeTaskCompleted() async {
    _stateSubject.add(SferaServiceState.loadingJourney);
    final requestJourneyTask = RequestJourneyProfileTask(
      mqttService: _mqttService,
      sferaDatabaseRepository: _sferaDatabaseRepository,
      otnId: _otnId!,
    );
    _tasks.add(requestJourneyTask);
    requestJourneyTask.execute(_onTaskCompleted, _onTaskFailed);
  }

  Future<void> _handleRequestJourneyProfileTaskCompleted(dynamic data) async {
    _stateSubject.add(SferaServiceState.loadingAdditionalData);
    final dataList = data as List;
    _journeyProfile = dataList.whereType<JourneyProfile>().first;
    _relatedTrainInformation = dataList.whereType<RelatedTrainInformation>().firstOrNull;
    _startSegmentProfileAndTCTask();
  }

  void _startSegmentProfileAndTCTask() {
    final requestSegmentProfilesTask = RequestSegmentProfilesTask(
      mqttService: _mqttService,
      sferaDatabaseRepository: _sferaDatabaseRepository,
      otnId: _otnId!,
      journeyProfile: _journeyProfile!,
    );
    _tasks.add(requestSegmentProfilesTask);
    requestSegmentProfilesTask.execute(_onTaskCompleted, _onTaskFailed);

    final requestTrainCharacteristicsTask = RequestTrainCharacteristicsTask(
      mqttService: _mqttService,
      sferaDatabaseRepository: _sferaDatabaseRepository,
      otnId: _otnId!,
      journeyProfile: _journeyProfile!,
    );
    _tasks.add(requestTrainCharacteristicsTask);
    requestTrainCharacteristicsTask.execute(_onTaskCompleted, _onTaskFailed);
  }

  bool _allTasksCompleted() => _tasks.whereType<SferaTask>().isEmpty;

  Future<void> _refreshSegmentProfiles() async {
    if (_journeyProfile == null) return;

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

  Future<void> _refreshTrainCharacteristics() async {
    if (_journeyProfile == null) return;

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

  void _updateJourney({VoidCallback? onSuccess, VoidCallback? onInvalid}) {
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
        onSuccess?.call();
      } else {
        Fimber.w('Failed to update journey as it is not valid');
        lastErrorCode = ErrorCode.sferaInvalid;
        onInvalid?.call();
      }
    }
  }

  void _addEventMessageHandlers() {
    _eventMessageHandlers.add(JourneyProfileEventHandler(_onJourneyProfileUpdated, _sferaDatabaseRepository));
    _eventMessageHandlers.add(RelatedTrainInformationEventHandler(_onRelatedTrainInformationUpdated));
    _eventMessageHandlers.add(NetworkSpecificEventHandler(_onNetworkSpecificEvent));
  }

  void _onJourneyProfileUpdated(SferaEventMessageHandler handler, JourneyProfile data) async {
    _journeyProfile = data;
    _startSegmentProfileAndTCTask();
  }

  void _onRelatedTrainInformationUpdated(SferaEventMessageHandler handler, RelatedTrainInformation data) async {
    _relatedTrainInformation = data;
    _updateJourney();
  }

  void _onNetworkSpecificEvent(SferaEventMessageHandler handler, NetworkSpecificEvent data) async {
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

  void _onTaskFailed(SferaTask task, ErrorCode errorCode) {
    Fimber.e('Task $task failed with error code $errorCode');
    _tasks.remove(task);
    lastErrorCode = errorCode;
    if (_stateSubject.value != SferaServiceState.connected) {
      disconnect();
    }
  }

  @override
  void dispose() {
    _mqttStreamSubscription?.cancel();
    _mqttStreamSubscription = null;
  }
}
