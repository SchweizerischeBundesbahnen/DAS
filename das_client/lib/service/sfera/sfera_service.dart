import 'dart:async';
import 'dart:core';

import 'package:das_client/model/sfera/journey_profile.dart';
import 'package:das_client/model/sfera/message_header.dart';
import 'package:das_client/model/sfera/otn_id.dart';
import 'package:das_client/model/sfera/segment_profile.dart';
import 'package:das_client/model/sfera/sfera_g2b_reply_message.dart';
import 'package:das_client/model/sfera/sfera_reply_parser.dart';
import 'package:das_client/model/sfera/train_identification.dart';
import 'package:das_client/repo/sfera_repository.dart';
import 'package:das_client/service/mqtt/mqtt_service.dart';
import 'package:das_client/service/sfera/handler/journey_profile_reply_handler.dart';
import 'package:das_client/service/sfera/handler/segment_profile_reply_handler.dart';
import 'package:das_client/service/sfera/handler/sfera_message_handler.dart';
import 'package:das_client/service/sfera/sfera_service_state.dart';
import 'package:das_client/service/sfera/task/handshake_task.dart';
import 'package:das_client/service/sfera/task/request_journey_profile_task.dart';
import 'package:das_client/service/sfera/task/sfera_task.dart';
import 'package:das_client/util/device_id_info.dart';
import 'package:das_client/util/error_code.dart';
import 'package:das_client/util/format.dart';
import 'package:fimber/fimber.dart';
import 'package:rxdart/rxdart.dart';
import 'package:uuid/uuid.dart';

class SferaService {
  final MqttService _mqttService;
  final SferaRepository _sferaRepository;

  StreamSubscription? _mqttStreamSubscription;
  StreamSubscription? _journeySubscription;
  final List<SferaMessageHandler> _messageHandlers = [];

  final _stateSubject = BehaviorSubject.seeded(SferaServiceState.disconnected);

  Stream<SferaServiceState> get stateStream => _stateSubject.stream;

  final _journeyProfileSubject = BehaviorSubject<JourneyProfile?>.seeded(null);

  Stream<JourneyProfile?> get journeyStream => _journeyProfileSubject.stream;

  final _segmentProfilesSubject = BehaviorSubject<List<SegmentProfile>>();

  Stream<List<SegmentProfile>> get segmentStream => _segmentProfilesSubject.stream;

  OtnId? otnId;
  ErrorCode? lastErrorCode;

  SferaService({required MqttService mqttService, required SferaRepository sferaRepository})
      : _mqttService = mqttService,
        _sferaRepository = sferaRepository {
    _init();
  }

  void _init() {
    _mqttStreamSubscription = _mqttService.messageStream.listen((message) async {
      var sferaG2bReplyMessage = SferaReplyParser.parse<SferaG2bReplyMessage>(message);
      if (!sferaG2bReplyMessage.validate()) {
        Fimber.w("Validation failed for MQTT response");
      }

      var handled = false;
      for (var handler in List.from(_messageHandlers)) {
        handled |= await handler.handleMessage(sferaG2bReplyMessage);
      }

      if (!handled) {
        Fimber.w("Could not handle sfera message $message");
      }
    });
  }

  Future<void> connect(OtnId otnId) async {
    Fimber.i("Starting new connection for $otnId");
    this.otnId = otnId;
    _messageHandlers.clear();
    lastErrorCode = null;
    _stateSubject.add(SferaServiceState.connecting);
    _observeJourneyProfile();

    if (await _mqttService.connect(otnId.company, sferaTrain(otnId.operationalTrainNumber, otnId.startDate))) {
      _stateSubject.add(SferaServiceState.handshaking);
      var handshakeTask = HandshakeTask(mqttService: _mqttService, otnId: otnId);
      _messageHandlers.add(handshakeTask);
      handshakeTask.execute(onTaskCompleted, onTaskFailed);
    } else {
      this.otnId = null;
      lastErrorCode = ErrorCode.connectionFailed;
      _stateSubject.add(SferaServiceState.disconnected);
    }
  }

  void _observeJourneyProfile() {
    _journeySubscription?.cancel();
    _journeySubscription = _sferaRepository
        .observeJourneyProfile(otnId!.company, otnId!.operationalTrainNumber, otnId!.startDate)
        .listen((journeyProfileList) async {
      var journeyProfile = journeyProfileList.firstOrNull?.toDomain();
      if (journeyProfile != null) {
        var segments = <SegmentProfile>[];

        for (var element in journeyProfile.segmentProfilesLists) {
          var segmentProfileEntity =
              await _sferaRepository.findSegmentProfile(element.spId, element.versionMajor, element.versionMinor);
          if (segmentProfileEntity != null) {
            segments.add(segmentProfileEntity.toDomain());
          } else {
            Fimber.w("Could not find segment profile for ${element.spId}");
          }
        }
        _segmentProfilesSubject.add(segments);
      }
      _journeyProfileSubject.add(journeyProfile);
    });
  }

  void onTaskCompleted(SferaTask task, dynamic data) {
    _messageHandlers.remove(task);
    Fimber.i("Task $task completed");
    if (task is HandshakeTask) {
      _stateSubject.add(SferaServiceState.loadingJourney);
      var requestJourneyTask =
          RequestJourneyProfileTask(mqttService: _mqttService, sferaRepository: _sferaRepository, otnId: otnId!);
      _messageHandlers.add(requestJourneyTask);
      requestJourneyTask.execute(onTaskCompleted, onTaskFailed);
    } else if (task is RequestJourneyProfileTask) {
      _addMessageHandlers();
      _stateSubject.add(SferaServiceState.connected);
    }
  }

  void _addMessageHandlers() {
    _messageHandlers.add(JourneyProfileReplyHandler(_sferaRepository));
    _messageHandlers.add(SegmentProfileReplyHandler(_sferaRepository));
  }

  void onTaskFailed(SferaTask task, ErrorCode errorCode) {
    _messageHandlers.remove(task);
    lastErrorCode = errorCode;
    Fimber.e("Task $task failed with error code $errorCode");
    if (task is HandshakeTask) {
      disconnect();
    }
  }

  void disconnect() {
    _mqttService.disconnect();
    _stateSubject.add(SferaServiceState.disconnected);
  }

  static Future<MessageHeader> messageHeader({TrainIdentification? trainIdentification}) async {
    return MessageHeader.create(const Uuid().v4(), Format.sferaTimestamp(DateTime.now()),
        await DeviceIdInfo.getDeviceId(), "TMS", await DeviceIdInfo.getDeviceId(), "TMS",
        trainIdentification: trainIdentification);
  }

  static String sferaTrain(String trainNumber, DateTime date) {
    return "${Format.sferaDate(date)}_$trainNumber";
  }
}
