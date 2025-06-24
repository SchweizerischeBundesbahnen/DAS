import 'package:logging/logging.dart';
import 'package:mqtt/component.dart';
import 'package:sfera/component.dart';
import 'package:sfera/src/data/api/task/sfera_task.dart';
import 'package:sfera/src/data/dto/b2g_request_dto.dart';
import 'package:sfera/src/data/dto/enums/sp_status_dto.dart';
import 'package:sfera/src/data/dto/journey_profile_dto.dart';
import 'package:sfera/src/data/dto/segment_profile_dto.dart';
import 'package:sfera/src/data/dto/segment_profile_list_dto.dart';
import 'package:sfera/src/data/dto/sfera_b2g_request_message_dto.dart';
import 'package:sfera/src/data/dto/sfera_g2b_reply_message_dto.dart';
import 'package:sfera/src/data/dto/sp_request_dto.dart';
import 'package:sfera/src/data/format.dart';
import 'package:sfera/src/data/local/sfera_local_database_service.dart';
import 'package:sfera/src/model/otn_id.dart';

final _log = Logger('RequestSegmentProfilesTask');

class RequestSegmentProfilesTask extends SferaTask<List<SegmentProfileDto>> {
  RequestSegmentProfilesTask({
    required MqttService mqttService,
    required SferaRemoteRepo sferaService,
    required SferaLocalDatabaseService sferaDatabaseRepository,
    required this.otnId,
    required this.journeyProfile,
    super.timeout,
  }) : _mqttService = mqttService,
       _sferaDatabaseRepository = sferaDatabaseRepository,
       _sferaService = sferaService;

  final MqttService _mqttService;
  final OtnId otnId;
  final SferaLocalDatabaseService _sferaDatabaseRepository;
  final SferaRemoteRepo _sferaService;
  final JourneyProfileDto journeyProfile;

  late TaskCompleted<List<SegmentProfileDto>> _taskCompletedCallback;
  late TaskFailed _taskFailedCallback;

  @override
  Future<void> execute(TaskCompleted<List<SegmentProfileDto>> onCompleted, TaskFailed onFailed) async {
    _taskCompletedCallback = onCompleted;
    _taskFailedCallback = onFailed;

    await _requestSegmentProfiles();
  }

  Future<void> _requestSegmentProfiles() async {
    final missingSp = await findMissingSegmentProfiles();
    if (missingSp.isEmpty) {
      _log.info('No missing SegmentProfiles found...');
      _taskCompletedCallback(this, []);
      return;
    }

    final List<SpRequestDto> spRequests = [];
    for (final sp in missingSp) {
      spRequests.add(
        SpRequestDto.create(
          id: sp.spId,
          versionMajor: sp.versionMajor,
          versionMinor: sp.versionMinor,
          spZone: sp.spZone,
        ),
      );
    }

    final sferaB2gRequestMessage = SferaB2gRequestMessageDto.create(
      _sferaService.messageHeader(sender: otnId.company),
      b2gRequest: B2gRequestDto.createSPRequest(spRequests),
    );
    _log.info('Sending segment profiles request...');

    startTimeout(_taskFailedCallback);
    final sferaTrain = Format.sferaTrain(otnId.operationalTrainNumber, otnId.startDate);
    _mqttService.publishMessage(otnId.company, sferaTrain, sferaB2gRequestMessage.buildDocument().toString());
  }

  Future<List<SegmentProfileReferenceDto>> findMissingSegmentProfiles() async {
    final missingSps = <SegmentProfileReferenceDto>[];

    for (final segment in journeyProfile.segmentProfileReferences) {
      final existingProfile = await _sferaDatabaseRepository.findSegmentProfile(
        segment.spId,
        segment.versionMajor,
        segment.versionMinor,
      );
      if (existingProfile == null) {
        missingSps.add(segment);
      }
    }

    return missingSps;
  }

  @override
  Future<bool> handleMessage(SferaG2bReplyMessageDto replyMessage) async {
    if (replyMessage.payload == null || replyMessage.payload!.segmentProfiles.isEmpty) {
      return false;
    }

    stopTimeout();
    _log.info(
      'Received G2bReplyPayload response with ${replyMessage.payload!.segmentProfiles.length} SegmentProfiles...',
    );

    bool allValid = true;

    for (final element in replyMessage.payload!.segmentProfiles) {
      if (element.status == SpStatusDto.valid) {
        await _sferaDatabaseRepository.saveSegmentProfile(element);
      } else {
        allValid = false;
      }
    }

    if (allValid) {
      _taskCompletedCallback(this, replyMessage.payload!.segmentProfiles.toList());
    } else {
      _taskFailedCallback(this, SferaError.invalid);
    }

    return true;
  }
}
