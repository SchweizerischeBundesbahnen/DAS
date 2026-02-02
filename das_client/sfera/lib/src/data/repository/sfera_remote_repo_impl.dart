import 'dart:async';
import 'dart:core';
import 'dart:ui';

import 'package:logging/logging.dart';
import 'package:mqtt/component.dart';
import 'package:rxdart/rxdart.dart';
import 'package:sfera/component.dart';
import 'package:sfera/src/data/api/event/journey_profile_event_handler.dart';
import 'package:sfera/src/data/api/event/network_specific_event_handler.dart';
import 'package:sfera/src/data/api/event/related_train_information_event_handler.dart';
import 'package:sfera/src/data/api/event/sfera_event_message_handler.dart';
import 'package:sfera/src/data/api/task/handshake_task.dart';
import 'package:sfera/src/data/api/task/request_journey_profile_task.dart';
import 'package:sfera/src/data/api/task/request_segment_profiles_task.dart';
import 'package:sfera/src/data/api/task/request_train_characteristics_task.dart';
import 'package:sfera/src/data/api/task/sfera_task.dart';
import 'package:sfera/src/data/dto/departure_dispatch_notification_event_dto.dart';
import 'package:sfera/src/data/dto/disturbance_msg_event_dto.dart';
import 'package:sfera/src/data/dto/enums/das_driving_mode_dto.dart';
import 'package:sfera/src/data/dto/journey_profile_dto.dart';
import 'package:sfera/src/data/dto/message_header_dto.dart';
import 'package:sfera/src/data/dto/network_specific_event_dto.dart';
import 'package:sfera/src/data/dto/related_train_information_dto.dart';
import 'package:sfera/src/data/dto/segment_profile_dto.dart';
import 'package:sfera/src/data/dto/sfera_b2g_event_message_dto.dart';
import 'package:sfera/src/data/dto/sfera_g2b_event_message_dto.dart';
import 'package:sfera/src/data/dto/sfera_g2b_reply_message_dto.dart';
import 'package:sfera/src/data/dto/sfera_xml_element_dto.dart';
import 'package:sfera/src/data/dto/train_characteristics_dto.dart';
import 'package:sfera/src/data/dto/ux_testing_nse_dto.dart';
import 'package:sfera/src/data/dto/warn_app_msg_dto.dart';
import 'package:sfera/src/data/format.dart';
import 'package:sfera/src/data/local/sfera_local_database_service.dart';
import 'package:sfera/src/data/local/tables/segment_profile_table.dart';
import 'package:sfera/src/data/local/tables/train_characteristics_table.dart';
import 'package:sfera/src/data/mapper/sfera_model_mapper.dart';
import 'package:sfera/src/model/otn_id.dart';
import 'package:uuid/uuid.dart';

final _log = Logger('SferaRemoteRepoImpl');

class SferaRemoteRepoImpl implements SferaRemoteRepo {
  SferaRemoteRepoImpl({
    required MqttService mqttService,
    required SferaLocalDatabaseService localService,
    required SferaAuthProvider authProvider,
    required this.deviceId,
  }) : _mqttService = mqttService,
       _localService = localService,
       _authProvider = authProvider {
    _initialize();
  }

  final String deviceId;
  final MqttService _mqttService;
  final SferaLocalDatabaseService _localService;
  final SferaAuthProvider _authProvider;

  StreamSubscription? _mqttStreamSubscription;
  final List<SferaTask> _tasks = [];
  final List<SferaEventMessageHandler> _eventMessageHandlers = [];

  OtnId? _otnId;
  JourneyProfileDto? _journeyProfile;
  final List<SegmentProfileDto> _segmentProfiles = [];
  final List<TrainCharacteristicsDto> _trainCharacteristics = [];
  RelatedTrainInformationDto? _relatedTrainInformation;

  final _rxState = BehaviorSubject<SferaRemoteRepositoryInternalState>.seeded(.disconnected);
  final _rxJourney = BehaviorSubject<Journey?>.seeded(null);
  final _rxUxTestingEvent = BehaviorSubject<UxTestingEvent?>.seeded(null);
  final _rxWarnappEvent = BehaviorSubject<WarnappEvent?>.seeded(null);
  final _rxDepartureDispatchNotificationEvent = BehaviorSubject<DepartureDispatchNotificationEvent?>.seeded(null);
  final _rxDisturbanceEvent = BehaviorSubject<DisturbanceEvent?>.seeded(null);

  // TODO: refactor _sferaService.stateStream & journeyUpdateStream & (connect / disconnect)
  // repository should not expose a state, should just expose data stream
  // once first listener tunes in, connect
  // once last listener cancels subscription, disconnect
  // refactor with viewModel change
  @override
  Stream<SferaRemoteRepositoryState> get stateStream => _rxState.map((s) => s.toExternalState()).distinct();

  @override
  Stream<Journey?> get journeyStream => _rxJourney.stream;

  @override
  Stream<UxTestingEvent?> get uxTestingEventStream => _rxUxTestingEvent.stream;

  @override
  Stream<WarnappEvent?> get warnappEventStream => _rxWarnappEvent.stream;

  @override
  Stream<DisturbanceEvent?> get disturbanceEventStream => _rxDisturbanceEvent.distinct();

  @override
  Stream<DepartureDispatchNotificationEvent?> get departureDispatchNotificationEventStream =>
      _rxDepartureDispatchNotificationEvent.stream;

  @override
  SferaError? lastError;

  /// Connects to SFERA broker and initiate Handshake with [HandshakeTask].
  /// Other tasks like loading SP, JPs and TCs are triggered on completion.
  @override
  Future<void> connect(TrainIdentification trainId) async {
    final OtnId otnId = _toOtnId(trainId);
    _log.info('Starting new connection for $otnId');
    _otnId = otnId;
    _tasks.clear();
    lastError = null;
    _rxState.add(.connecting);

    final sferaTrain = Format.sferaTrain(otnId.operationalTrainNumber, otnId.startDate);
    final isConnected = await _mqttService.connect(otnId.company, sferaTrain);
    if (isConnected) {
      await _initiateHandshake(otnId);
    } else {
      _otnId = null;
      lastError = .connectionFailed();
      _rxState.add(.disconnected);
    }
  }

  OtnId _toOtnId(TrainIdentification trainId) {
    final otnId = OtnId(
      company: trainId.ru.companyCode,
      operationalTrainNumber: trainId.trainNumber,
      startDate: trainId.date,
    );
    return otnId;
  }

  /// Sends [SessionTermination] and disconnects from SFERA broker.
  ///
  /// Disconnect is either called by the user or when one of the [SferaTask] fails and no journey was loaded yet - i.e. the service is not in the [SferaRemoteRepositoryInternalState.connected].
  @override
  Future<void> disconnect() async {
    final otnId = _otnId;
    if (_rxState.value == .connected && otnId != null) {
      _log.info('Sending session termination request for $otnId...');
      final header = messageHeader(sender: otnId.company);
      final sessionTerminationMessage = SferaB2gEventMessageDto.createSessionTermination(messageHeader: header);
      final sferaTrain = Format.sferaTrain(otnId.operationalTrainNumber, otnId.startDate);
      _mqttService.publishMessage(otnId.company, sferaTrain, sessionTerminationMessage.buildDocument().toString());
    }

    _mqttService.disconnect();
    _rxJourney.add(null);
    _rxDepartureDispatchNotificationEvent.add(null);
    _rxUxTestingEvent.add(null);
    _rxWarnappEvent.add(null);
    _rxDisturbanceEvent.add(null);
    _rxState.add(.disconnected);
  }

  @override
  void dispose() {
    _rxJourney.close();
    _rxState.close();
    _rxUxTestingEvent.close();
    _rxDepartureDispatchNotificationEvent.close();
    _mqttStreamSubscription?.cancel();
    _mqttStreamSubscription = null;
    _rxWarnappEvent.close();
    _rxDisturbanceEvent.close();
  }

  @override
  MessageHeaderDto messageHeader({required String sender}) {
    final timestamp = Format.sferaTimestamp(DateTime.now());
    return MessageHeaderDto.create(const Uuid().v4(), timestamp, deviceId, 'TMS', sender, '0085');
  }

  void _initialize() {
    _addEventMessageHandlers();
    _mqttStreamSubscription = _mqttService.messageStream.listen(_handleMqttMessage);
  }

  void _handleMqttMessage(String xmlMessage) async {
    final message = SferaReplyParser.parse<SferaXmlElementDto>(xmlMessage);
    if (!message.validate()) {
      _log.warning('Validation failed for MQTT response $xmlMessage');
      return;
    }

    if (message is SferaG2bReplyMessageDto) {
      await _handleReplyMessage(message, xmlMessage);
    } else if (message is SferaG2bEventMessageDto) {
      await _handleEventMessage(message, xmlMessage);
    }
  }

  Future<void> _handleReplyMessage(SferaG2bReplyMessageDto message, String xmlMessage) async {
    var handled = false;
    for (final handler in List.from(_tasks)) {
      handled |= await handler.handleMessage(message);
    }

    if (!handled) {
      _log.warning('Could not handle Sfera reply message $xmlMessage');
    }
  }

  Future<void> _handleEventMessage(SferaG2bEventMessageDto message, String xmlMessage) async {
    var handled = false;
    for (final handler in List.from(_eventMessageHandlers)) {
      handled |= await handler.handleMessage(message);
    }

    if (!handled) {
      _log.warning('Could not handle Sfera event message $xmlMessage');
    }
  }

  Future<void> _initiateHandshake(OtnId otnId) async {
    _rxState.add(.handshaking);
    final isDriver = await _authProvider.isDriver();
    final DasDrivingModeDto drivingMode = isDriver ? .dasNotConnected : .readOnly;

    final handshakeTask = HandshakeTask(
      mqttService: _mqttService,
      sferaService: this,
      otnId: otnId,
      dasDrivingMode: drivingMode,
    );
    _tasks.add(handshakeTask);
    handshakeTask.execute(_onTaskCompleted, _onTaskFailed);
  }

  void _onTaskCompleted(SferaTask task, dynamic data) async {
    _tasks.remove(task);
    _log.info('Task $task completed');
    switch (task) {
      case HandshakeTask _:
        await _handleHandshakeTaskCompleted();
      case RequestJourneyProfileTask _:
        await _handleRequestJourneyProfileTaskCompleted(data);
    }

    if (_allTasksCompleted()) {
      switch (_rxState.value) {
        case .loadingAdditionalData:
          await _refreshSegmentProfiles();
          await _refreshTrainCharacteristics();
          _updateJourney(
            onSuccess: () => _rxState.add(.connected),
            onInvalid: () => disconnect(),
          );
          break;
        case .connected:
          await _refreshSegmentProfiles();
          await _refreshTrainCharacteristics();
          _updateJourney();
          break;
        default:
      }
    }
  }

  Future<void> _handleHandshakeTaskCompleted() async {
    _rxState.add(.loadingJourney);
    final requestJourneyTask = RequestJourneyProfileTask(
      mqttService: _mqttService,
      sferaService: this,
      sferaDatabaseRepository: _localService,
      otnId: _otnId!,
    );
    _tasks.add(requestJourneyTask);
    requestJourneyTask.execute(_onTaskCompleted, _onTaskFailed);
  }

  Future<void> _handleRequestJourneyProfileTaskCompleted(dynamic data) async {
    _rxState.add(.loadingAdditionalData);
    final dataList = data as List;
    _journeyProfile = dataList.whereType<JourneyProfileDto>().first;
    _relatedTrainInformation = dataList.whereType<RelatedTrainInformationDto>().firstOrNull;
    _startSegmentProfileAndTCTask();
  }

  void _startSegmentProfileAndTCTask() {
    final requestSegmentProfilesTask = RequestSegmentProfilesTask(
      sferaService: this,
      mqttService: _mqttService,
      sferaDatabaseRepository: _localService,
      otnId: _otnId!,
      journeyProfile: _journeyProfile!,
    );
    _tasks.add(requestSegmentProfilesTask);
    requestSegmentProfilesTask.execute(_onTaskCompleted, _onTaskFailed);

    final requestTrainCharacteristicsTask = RequestTrainCharacteristicsTask(
      sferaService: this,
      mqttService: _mqttService,
      sferaDatabaseRepository: _localService,
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
      final segmentProfileEntity = await _localService.findSegmentProfile(
        element.spId,
        element.versionMajor,
        element.versionMinor,
      );
      final segmentProfile = segmentProfileEntity?.toDomain();
      if (segmentProfile != null && segmentProfile.validate()) {
        _segmentProfiles.add(segmentProfile);
      } else {
        _log.warning('Could not find and validate segment profile for ${element.spId}');
      }
    }
  }

  Future<void> _refreshTrainCharacteristics() async {
    if (_journeyProfile == null) return;

    _trainCharacteristics.clear();

    for (final element in _journeyProfile!.trainCharacteristicsRefSet) {
      final trainCharacteristicsEntity = await _localService.findTrainCharacteristics(
        element.tcId,
        element.versionMajor,
        element.versionMinor,
      );
      final trainCharacteristics = trainCharacteristicsEntity?.toDomain();
      if (trainCharacteristics != null && trainCharacteristics.validate()) {
        _trainCharacteristics.add(trainCharacteristics);
      } else {
        _log.warning('Could not find and validate $element');
      }
    }
  }

  void _updateJourney({VoidCallback? onSuccess, VoidCallback? onInvalid}) {
    if (_journeyProfile != null && _segmentProfiles.isNotEmpty) {
      _log.fine('Updating journey stream...');
      final newJourney = SferaModelMapper.mapToJourney(
        journeyProfile: _journeyProfile!,
        segmentProfiles: _segmentProfiles,
        trainCharacteristics: _trainCharacteristics,
        relatedTrainInformation: _relatedTrainInformation,
      );
      if (newJourney.valid) {
        _rxJourney.add(newJourney);
        _log.fine('Journey updates successfully.');
        onSuccess?.call();
      } else {
        _log.warning('Failed to update journey as it is not valid');
        lastError = .invalid();
        onInvalid?.call();
      }
    }
  }

  void _addEventMessageHandlers() {
    _eventMessageHandlers.add(JourneyProfileEventHandler(_onJourneyProfileUpdated, _localService));
    _eventMessageHandlers.add(RelatedTrainInformationEventHandler(_onRelatedTrainInformationUpdated));
    _eventMessageHandlers.add(NetworkSpecificEventHandler(_onNetworkSpecificEvent));
  }

  void _onJourneyProfileUpdated(SferaEventMessageHandler _, JourneyProfileDto data) async {
    _journeyProfile = data;
    _startSegmentProfileAndTCTask();
  }

  void _onRelatedTrainInformationUpdated(SferaEventMessageHandler _, RelatedTrainInformationDto data) async {
    _relatedTrainInformation = data;
    _updateJourney();
  }

  void _onNetworkSpecificEvent(SferaEventMessageHandler _, NetworkSpecificEventDto data) async {
    if (data is UxTestingNseDto) {
      if (data.koa != null) {
        final event = UxTestingEvent(name: data.koa!.name, value: data.koa!.nspValue);
        _rxUxTestingEvent.add(event);
      }

      if (data.warn != null) {
        final event = UxTestingEvent(name: data.warn!.name, value: data.warn!.nspValue);
        _rxUxTestingEvent.add(event);
      }

      if (data.connectivity != null) {
        final event = UxTestingEvent(name: data.connectivity!.name, value: data.connectivity!.nspValue);
        _rxUxTestingEvent.add(event);
      }
    }

    if (data is WarnAppMsgDto) {
      _rxWarnappEvent.add(WarnappEvent());
    }

    if (data is DisturbanceMsgEventDto) {
      _rxDisturbanceEvent.add(DisturbanceEvent(type: data.disturbanceMsgNsp.disturbanceMsgType.type));
    }

    if (data is DepartureDispatchNotificationEventDto) {
      _rxDepartureDispatchNotificationEvent.add(DepartureDispatchNotificationEvent(type: data.message.unwrapped.type));
    }
  }

  void _onTaskFailed(SferaTask task, SferaError error) {
    _log.severe('Task $task failed with error $error');
    _tasks.remove(task);
    lastError = error;
    if (_rxState.value != .connected) {
      disconnect();
    }
  }

  @override
  TrainIdentification? get connectedTrain => _otnId != null
      ? TrainIdentification(
          ru: .fromCompanyCode(_otnId!.company),
          trainNumber: _otnId!.operationalTrainNumber,
          date: _otnId!.startDate,
        )
      : null;
}

enum SferaRemoteRepositoryInternalState {
  disconnected,
  connecting,
  handshaking,
  loadingJourney,
  loadingAdditionalData,
  connected,
  offline
  ;

  SferaRemoteRepositoryState toExternalState() => switch (this) {
    .disconnected || .offline => .disconnected,
    .connecting || .handshaking || .loadingJourney || .loadingAdditionalData => .connecting,
    .connected => .connected,
  };
}
