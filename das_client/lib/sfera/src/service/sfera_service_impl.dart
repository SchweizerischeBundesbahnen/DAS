import 'dart:async';
import 'dart:core';

import 'package:das_client/auth/authentication_component.dart';
import 'package:das_client/mqtt/mqtt_component.dart';
import 'package:das_client/sfera/sfera_component.dart';
import 'package:das_client/sfera/src/model/enums/das_driving_mode.dart';
import 'package:das_client/sfera/src/service/handler/journey_profile_reply_handler.dart';
import 'package:das_client/sfera/src/service/handler/segment_profile_reply_handler.dart';
import 'package:das_client/sfera/src/service/handler/sfera_message_handler.dart';
import 'package:das_client/sfera/src/service/task/handshake_task.dart';
import 'package:das_client/sfera/src/service/task/request_journey_profile_task.dart';
import 'package:das_client/sfera/src/service/task/request_segment_profiles_task.dart';
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

  final _journeyProfileSubject = BehaviorSubject<JourneyProfile?>.seeded(null);

  @override
  Stream<JourneyProfile?> get journeyStream => _journeyProfileSubject.stream;

  final _segmentProfilesSubject = BehaviorSubject<List<SegmentProfile>>();

  @override
  Stream<List<SegmentProfile>> get segmentStream => _segmentProfilesSubject.stream;

  OtnId? otnId;

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
        Fimber.w('Validation failed for MQTT response');
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
    this.otnId = otnId;
    _messageHandlers.clear();
    lastErrorCode = null;
    _stateSubject.add(SferaServiceState.connecting);

    if (await _mqttService.connect(
        otnId.company, SferaService.sferaTrain(otnId.operationalTrainNumber, otnId.startDate))) {
      _stateSubject.add(SferaServiceState.handshaking);
      final user = await _authenticator.user();
      final drivingMode = user.roles.contains(Role.lokpersonal) ? DasDrivingMode.dasNotConnected : DasDrivingMode.readOnly;

      final handshakeTask = HandshakeTask(mqttService: _mqttService, otnId: otnId, dasDrivingMode: drivingMode);
      _messageHandlers.add(handshakeTask);
      handshakeTask.execute(onTaskCompleted, onTaskFailed);
    } else {
      this.otnId = null;
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
          RequestJourneyProfileTask(mqttService: _mqttService, sferaRepository: _sferaRepository, otnId: otnId!);
      _messageHandlers.add(requestJourneyTask);
      requestJourneyTask.execute(onTaskCompleted, onTaskFailed);
    } else if (task is RequestJourneyProfileTask) {
      _stateSubject.add(SferaServiceState.loadingSegments);
      final requestSegmentProfilesTask = RequestSegmentProfilesTask(
          mqttService: _mqttService, sferaRepository: _sferaRepository, otnId: otnId!, journeyProfile: data);
      _journeyProfileSubject.add(data);
      _messageHandlers.add(requestSegmentProfilesTask);
      requestSegmentProfilesTask.execute(onTaskCompleted, onTaskFailed);
    } else if (task is RequestSegmentProfilesTask) {
      _addMessageHandlers();
      await _refreshSegmentProfiles();
      _stateSubject.add(SferaServiceState.connected);
    }
  }

  Future<void> _refreshSegmentProfiles() async {
    if (_journeyProfileSubject.value != null) {
      final segments = <SegmentProfile>[];

      for (final element in _journeyProfileSubject.value!.segmentProfilesLists) {
        final segmentProfileEntity =
            await _sferaRepository.findSegmentProfile(element.spId, element.versionMajor, element.versionMinor);
        if (segmentProfileEntity != null) {
          segments.add(segmentProfileEntity.toDomain());
        } else {
          Fimber.w('Could not find segment profile for ${element.spId}');
        }
      }
      _segmentProfilesSubject.add(segments);
    }
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
