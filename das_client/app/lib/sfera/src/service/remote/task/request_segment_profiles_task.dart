import 'package:app/mqtt/mqtt_component.dart';
import 'package:app/sfera/src/db/repo/sfera_database_repository.dart';
import 'package:app/sfera/src/model/b2g_request.dart';
import 'package:app/sfera/src/model/enums/sp_status.dart';
import 'package:app/sfera/src/model/journey_profile.dart';
import 'package:app/sfera/src/model/otn_id.dart';
import 'package:app/sfera/src/model/segment_profile.dart';
import 'package:app/sfera/src/model/segment_profile_list.dart';
import 'package:app/sfera/src/model/sfera_b2g_request_message.dart';
import 'package:app/sfera/src/model/sfera_g2b_reply_message.dart';
import 'package:app/sfera/src/model/sp_request.dart';
import 'package:app/sfera/src/service/remote/sfera_service.dart';
import 'package:app/sfera/src/service/remote/task/sfera_task.dart';
import 'package:app/util/error_code.dart';
import 'package:fimber/fimber.dart';

class RequestSegmentProfilesTask extends SferaTask<List<SegmentProfile>> {
  RequestSegmentProfilesTask({
    required MqttService mqttService,
    required SferaDatabaseRepository sferaDatabaseRepository,
    required this.otnId,
    required this.journeyProfile,
    super.timeout,
  })  : _mqttService = mqttService,
        _sferaDatabaseRepository = sferaDatabaseRepository;

  final MqttService _mqttService;
  final OtnId otnId;
  final SferaDatabaseRepository _sferaDatabaseRepository;
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
    final missingSp = await findMissingSegmentProfiles();
    if (missingSp.isEmpty) {
      Fimber.i('No missing SegmentProfiles found...');
      _taskCompletedCallback(this, []);
      return;
    }

    final List<SpRequest> spRequests = [];
    for (final sp in missingSp) {
      spRequests.add(SpRequest.create(
          id: sp.spId, versionMajor: sp.versionMajor, versionMinor: sp.versionMinor, spZone: sp.spZone));
    }

    final sferaB2gRequestMessage = SferaB2gRequestMessage.create(
      await SferaService.messageHeader(sender: otnId.company),
      b2gRequest: B2gRequest.createSPRequest(spRequests),
    );
    Fimber.i('Sending segment profiles request...');

    startTimeout(_taskFailedCallback);
    final sferaTrain = SferaService.sferaTrain(otnId.operationalTrainNumber, otnId.startDate);
    _mqttService.publishMessage(otnId.company, sferaTrain, sferaB2gRequestMessage.buildDocument().toString());
  }

  Future<List<SegmentProfileReference>> findMissingSegmentProfiles() async {
    final missingSps = <SegmentProfileReference>[];

    for (final segment in journeyProfile.segmentProfileReferences) {
      final existingProfile =
          await _sferaDatabaseRepository.findSegmentProfile(segment.spId, segment.versionMajor, segment.versionMinor);
      if (existingProfile == null) {
        missingSps.add(segment);
      }
    }

    return missingSps;
  }

  @override
  Future<bool> handleMessage(SferaG2bReplyMessage replyMessage) async {
    if (replyMessage.payload == null || replyMessage.payload!.segmentProfiles.isEmpty) {
      return false;
    }

    stopTimeout();
    Fimber.i(
      'Received G2bReplyPayload response with ${replyMessage.payload!.segmentProfiles.length} SegmentProfiles...',
    );

    bool allValid = true;

    for (final element in replyMessage.payload!.segmentProfiles) {
      if (element.status == SpStatus.valid) {
        await _sferaDatabaseRepository.saveSegmentProfile(element);
      } else {
        allValid = false;
      }
    }

    if (allValid) {
      _taskCompletedCallback(this, replyMessage.payload!.segmentProfiles.toList());
    } else {
      _taskFailedCallback(this, ErrorCode.sferaInvalid);
    }

    return true;
  }
}
