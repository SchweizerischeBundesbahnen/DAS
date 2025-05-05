import 'package:sfera/src/db/repo/sfera_database_repository.dart';
import 'package:sfera/src/model/b2g_request.dart';
import 'package:sfera/src/model/enums/jp_status.dart';
import 'package:sfera/src/model/jp_request.dart';
import 'package:sfera/src/model/otn_id.dart';
import 'package:sfera/src/model/sfera_b2g_request_message.dart';
import 'package:sfera/src/model/sfera_g2b_reply_message.dart';
import 'package:sfera/src/model/train_identification.dart';
import 'package:sfera/src/service/remote/sfera_service.dart';
import 'package:sfera/src/service/remote/task/sfera_task.dart';
import 'package:app/util/error_code.dart';
import 'package:fimber/fimber.dart';
import 'package:mqtt/component.dart';

class RequestJourneyProfileTask extends SferaTask<List<dynamic>> {
  RequestJourneyProfileTask({
    required MqttService mqttService,
    required SferaDatabaseRepository sferaDatabaseRepository,
    required this.otnId,
    super.timeout,
  })  : _mqttService = mqttService,
        _sferaDatabaseRepository = sferaDatabaseRepository;

  final MqttService _mqttService;
  final OtnId otnId;
  final SferaDatabaseRepository _sferaDatabaseRepository;

  late TaskCompleted<List<dynamic>> _taskCompletedCallback;
  late TaskFailed _taskFailedCallback;

  @override
  Future<void> execute(TaskCompleted<List<dynamic>> onCompleted, TaskFailed onFailed) async {
    _taskCompletedCallback = onCompleted;
    _taskFailedCallback = onFailed;

    await _requestJourneyProfile();
    startTimeout(_taskFailedCallback);
  }

  Future<void> _requestJourneyProfile() async {
    final trainIdentification = TrainIdentification.create(otnId: otnId);
    final jpRequest = JpRequest.create(trainIdentification);

    final sferaB2gRequestMessage = SferaB2gRequestMessage.create(
        await SferaService.messageHeader(sender: otnId.company),
        b2gRequest: B2gRequest.createJPRequest(jpRequest));
    Fimber.i('Sending journey profile request...');
    _mqttService.publishMessage(otnId.company, SferaService.sferaTrain(otnId.operationalTrainNumber, otnId.startDate),
        sferaB2gRequestMessage.buildDocument().toString());
  }

  @override
  Future<bool> handleMessage(SferaG2bReplyMessage replyMessage) async {
    if (replyMessage.payload == null || replyMessage.payload!.journeyProfiles.isEmpty) {
      return false;
    }

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
      'Received G2bReplyPayload response with ${replyMessage.payload!.journeyProfiles.length} JourneyProfiles, '
      '${replyMessage.payload!.segmentProfiles.length} SegmentProfiles and '
      '${replyMessage.payload!.trainCharacteristics.length} TrainCharacteristics...',
    );

    for (final element in replyMessage.payload!.segmentProfiles) {
      await _sferaDatabaseRepository.saveSegmentProfile(element);
    }

    for (final trainCharacteristics in replyMessage.payload!.trainCharacteristics) {
      await _sferaDatabaseRepository.saveTrainCharacteristics(trainCharacteristics);
    }

    for (final journeyProfile in replyMessage.payload!.journeyProfiles) {
      await _sferaDatabaseRepository.saveJourneyProfile(journeyProfile);
    }

    final result = [];
    result.addAll(replyMessage.payload!.journeyProfiles);
    result.addAll(replyMessage.payload!.segmentProfiles);
    result.addAll(replyMessage.payload!.trainCharacteristics);
    result.addAll(replyMessage.payload!.relatedTrainInformation);

    _taskCompletedCallback(this, result);
    return true;
  }
}
