import 'package:das_client/mqtt/mqtt_component.dart';
import 'package:das_client/sfera/src/model/b2g_request.dart';
import 'package:das_client/sfera/src/model/enums/jp_status.dart';
import 'package:das_client/sfera/src/model/journey_profile.dart';
import 'package:das_client/sfera/src/model/jp_request.dart';
import 'package:das_client/sfera/src/model/otn_id.dart';
import 'package:das_client/sfera/src/model/sfera_b2g_request_message.dart';
import 'package:das_client/sfera/src/model/sfera_g2b_reply_message.dart';
import 'package:das_client/sfera/src/model/train_identification.dart';
import 'package:das_client/sfera/src/repo/sfera_repository.dart';
import 'package:das_client/sfera/src/service/sfera_service.dart';
import 'package:das_client/sfera/src/service/task/sfera_task.dart';
import 'package:das_client/util/error_code.dart';
import 'package:fimber/fimber.dart';

class RequestJourneyProfileTask extends SferaTask<JourneyProfile> {
  RequestJourneyProfileTask(
      {required MqttService mqttService, required SferaRepository sferaRepository, required this.otnId, super.timeout})
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
    final trainIdentification = TrainIdentification.create(otnId: otnId);
    final jpRequest = JpRequest.create(trainIdentification);

    final sferaB2gRequestMessage = SferaB2gRequestMessage.create(
        await SferaService.messageHeader(trainIdentification: trainIdentification, sender: otnId.company),
        b2gRequest: B2gRequest.createJPRequest(jpRequest));
    Fimber.i('Sending journey profile request...');
    _mqttService.publishMessage(otnId.company, SferaService.sferaTrain(otnId.operationalTrainNumber, otnId.startDate),
        sferaB2gRequestMessage.buildDocument().toString());
  }

  @override
  Future<bool> handleMessage(SferaG2bReplyMessage replyMessage) async {
    if (replyMessage.payload != null && replyMessage.payload!.journeyProfiles.isNotEmpty) {
      stopTimeout();
      final journeyProfile = replyMessage.payload!.journeyProfiles.first;
      if (journeyProfile.status == JpStatus.invalid || journeyProfile.status == JpStatus.unavailable) {
        Fimber.w(
          'Received JourneyProfile with status=${journeyProfile.status}.',
        );
        _taskFailedCallback(this, ErrorCode.sferaJpUnavailable);
        return true;
      }

      Fimber.i(
        'Received G2bReplyPayload response with ${replyMessage.payload!.journeyProfiles.length} JourneyProfiles and ${replyMessage.payload!.segmentProfiles.length} SegmentProfiles...',
      );

      for (final element in replyMessage.payload!.segmentProfiles) {
        await _sferaRepository.saveSegmentProfile(element);
      }

      for (final journeyProfile in replyMessage.payload!.journeyProfiles) {
        await _sferaRepository.saveJourneyProfile(journeyProfile);
      }

      _taskCompletedCallback(this, replyMessage.payload!.journeyProfiles.first);
      return true;
    }
    return false;
  }
}
