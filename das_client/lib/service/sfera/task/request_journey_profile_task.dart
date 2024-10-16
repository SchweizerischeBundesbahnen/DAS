import 'package:das_client/model/sfera/b2g_request.dart';
import 'package:das_client/model/sfera/journey_profile.dart';
import 'package:das_client/model/sfera/jp_request.dart';
import 'package:das_client/model/sfera/otn_id.dart';
import 'package:das_client/model/sfera/sfera_b2g_request_message.dart';
import 'package:das_client/model/sfera/sfera_g2b_reply_message.dart';
import 'package:das_client/model/sfera/train_identification.dart';
import 'package:das_client/repo/sfera_repository.dart';
import 'package:das_client/service/mqtt/mqtt_service.dart';
import 'package:das_client/service/sfera/sfera_service.dart';
import 'package:das_client/service/sfera/task/sfera_task.dart';
import 'package:fimber/fimber.dart';

class RequestJourneyProfileTask extends SferaTask<JourneyProfile> {
  RequestJourneyProfileTask(
      {required MqttService mqttService,
      required SferaRepository sferaRepository,
      required this.otnId,
      super.timeout})
      : _mqttService = mqttService,
        _sferaRepository = sferaRepository;

  final MqttService _mqttService;
  final OtnId otnId;
  final SferaRepository _sferaRepository;

  late TaskCompleted<JourneyProfile> _taskCompletedCallback;
  late TaskFailed _taskFailedCallback;

  @override
  Future<void> execute(TaskCompleted<JourneyProfile> onCompleted, TaskFailed onFailed) async {
    _taskCompletedCallback = onCompleted;
    _taskFailedCallback = onFailed;

    await _requestJourneyProfile();
    startTimeout(_taskFailedCallback);
  }

  Future<void> _requestJourneyProfile() async {
    var trainIdentification = TrainIdentification.create(otnId: otnId);
    var jpRequest = JpRequest.create(trainIdentification);

    var sferaB2gRequestMessage = SferaB2gRequestMessage.create(
        await SferaService.messageHeader(trainIdentification: trainIdentification),
        b2gRequest: B2gRequest.create(jpRequest: jpRequest));
    Fimber.i("Sending journey profile request...");
    _mqttService.publishMessage(otnId.company, SferaService.sferaTrain(otnId.operationalTrainNumber, otnId.startDate),
        sferaB2gRequestMessage.buildDocument().toString());
  }

  @override
  Future<bool> handleMessage(SferaG2bReplyMessage replyMessage) async {
    if (replyMessage.payload != null && replyMessage.payload!.journeyProfiles.isNotEmpty) {
      stopTimeout();
      Fimber.i(
        "Received G2bReplyPayload response with ${replyMessage.payload!.journeyProfiles.length} JourneyProfiles and ${replyMessage.payload!.segmentProfiles.length} SegmentProfiles...",
      );

      for (var element in replyMessage.payload!.segmentProfiles) {
        await _sferaRepository.saveSegmentProfile(element);
      }

      for (var journeyProfile in replyMessage.payload!.journeyProfiles) {
        await _sferaRepository.saveJourneyProfile(journeyProfile);
      }

      _taskCompletedCallback(this, replyMessage.payload!.journeyProfiles.first);
      return true;
    }
    return false;
  }
}
