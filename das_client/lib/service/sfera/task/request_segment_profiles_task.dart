import 'package:das_client/model/sfera/b2g_request.dart';
import 'package:das_client/model/sfera/journey_profile.dart';
import 'package:das_client/model/sfera/otn_id.dart';
import 'package:das_client/model/sfera/segment_profile.dart';
import 'package:das_client/model/sfera/segment_profile_list.dart';
import 'package:das_client/model/sfera/sfera_b2g_request_message.dart';
import 'package:das_client/model/sfera/sfera_g2b_reply_message.dart';
import 'package:das_client/model/sfera/sp_request.dart';
import 'package:das_client/model/sfera/train_identification.dart';
import 'package:das_client/repo/sfera_repository.dart';
import 'package:das_client/service/mqtt/mqtt_service.dart';
import 'package:das_client/service/sfera/sfera_service.dart';
import 'package:das_client/service/sfera/task/sfera_task.dart';
import 'package:fimber/fimber.dart';

class RequestSegmentProfilesTask extends SferaTask<List<SegmentProfile>> {
  RequestSegmentProfilesTask({required MqttService mqttService,
    required SferaRepository sferaRepository,
    required this.otnId,
    required this.journeyProfile,
    super.timeout})
      : _mqttService = mqttService,
        _sferaRepository = sferaRepository;

  final MqttService _mqttService;
  final OtnId otnId;
  final SferaRepository _sferaRepository;
  final JourneyProfile journeyProfile;

  late TaskCompleted<List<SegmentProfile>> _taskCompletedCallback;
  late TaskFailed _taskFailedCallback;

  @override
  Future<void> execute(TaskCompleted<List<SegmentProfile>> onCompleted, TaskFailed onFailed) async {
    _taskCompletedCallback = onCompleted;
    _taskFailedCallback = onFailed;

    await _requestSegmentProfiles();
  }

  Future<void> _requestSegmentProfiles() async {

    var missingSp = await findMissingSegmentProfiles();
    if (missingSp.isEmpty) {
      Fimber.i('No missing SegmentProfiles found...');
      _taskCompletedCallback(this, []);
      return;
    }

    List<SpRequest> spRequests = [];
    for (var sp in missingSp) {
      spRequests.add(SpRequest.create(id: sp.spId, versionMajor: sp.versionMajor, versionMinor: sp.versionMinor, spZone: sp.spZone));
    }

    var trainIdentification = TrainIdentification.create(otnId: otnId);
    var sferaB2gRequestMessage = SferaB2gRequestMessage.create(
        await SferaService.messageHeader(trainIdentification: trainIdentification),
        b2gRequest: B2gRequest.createSPRequest(spRequests));
    Fimber.i('Sending segment profiles request...');

    startTimeout(_taskFailedCallback);
    _mqttService.publishMessage(otnId.company, SferaService.sferaTrain(otnId.operationalTrainNumber, otnId.startDate),
        sferaB2gRequestMessage.buildDocument().toString());
  }

  Future<List<SegmentProfileList>> findMissingSegmentProfiles() async {
    var missingSps = <SegmentProfileList>[];

    for (var segment in journeyProfile.segmentProfilesLists) {
      var existingProfile = await _sferaRepository.findSegmentProfile(
          segment.spId, segment.versionMajor, segment.versionMinor);
      if (existingProfile == null) {
        missingSps.add(segment);
      }
    }

    return missingSps;
  }

  @override
  Future<bool> handleMessage(SferaG2bReplyMessage replyMessage) async {
    if (replyMessage.payload != null && replyMessage.payload!.segmentProfiles.isNotEmpty) {
      stopTimeout();
      Fimber.i(
        'Received G2bReplyPayload response with ${replyMessage.payload!.segmentProfiles.length} SegmentProfiles...',
      );

      for (var element in replyMessage.payload!.segmentProfiles) {
        await _sferaRepository.saveSegmentProfile(element);
      }

      _taskCompletedCallback(this, replyMessage.payload!.segmentProfiles.toList());
      return true;
    }
    return false;
  }
}
