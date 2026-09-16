import 'package:core_data/component.dart';
import 'package:logging/logging.dart';
import 'package:mqtt/component.dart';
import 'package:sfera/component.dart';
import 'package:sfera/src/data/api/task/sfera_task.dart';
import 'package:sfera/src/data/dto/b2g_request_dto.dart';
import 'package:sfera/src/data/dto/g2b_error.dart';
import 'package:sfera/src/data/dto/sfera_b2g_request_message_dto.dart';
import 'package:sfera/src/data/dto/sfera_g2b_reply_message_dto.dart';
import 'package:sfera/src/data/dto/sp_request_dto.dart';
import 'package:sfera/src/data/dto/sp_zone_dto.dart';
import 'package:sfera/src/data/format.dart';
import 'package:sfera/src/data/local/sfera_local_database_service.dart';
import 'package:sfera/src/model/otn_id.dart';

final _log = Logger('RequestLocalRegulationsTask');

class RequestLocalRegulationsTask({
  required final MqttService _mqttService,
  required final SferaRepository _sferaRepo,
  required final SferaLocalDatabaseService _sferaDatabaseRepository,
  required final OtnId otnId,
  required final List<ServicePoint> servicePoints,
  super.timeout,
}) extends SferaTask<void> {
  static final localRegulationVersionMajor = '0';
  static final localRegulationVersionMinor = '';

  late TaskCompleted<void> _taskCompletedCallback;
  late TaskFailed _taskFailedCallback;

  int _segementsToFetch = 0;

  @override
  Future<void> execute(TaskCompleted<void> onCompleted, TaskFailed onFailed) async {
    _taskCompletedCallback = onCompleted;
    _taskFailedCallback = onFailed;

    await _requestLocalRegulations();
  }

  @override
  Future<bool> handleMessage(SferaG2bReplyMessageDto replyMessage) async {
    if (replyMessage.hasErrors) {
      final errors = replyMessage.payload!.messageResponse!.errors;
      _log.info('Received reply with errors $errors');
      _taskFailedCallback(this, .protocolError(errors: errors.map((error) => error.toProtocolError)));
      stopTimeout();
      return false;
    }

    if (replyMessage.payload == null || replyMessage.payload!.segmentProfiles.isEmpty) {
      return false;
    }

    stopTimeout();
    final segmentProfileCount = replyMessage.payload!.segmentProfiles.length;
    _log.info(
      'Received G2bReplyPayload response with $segmentProfileCount local regulation SegmentProfiles...',
    );

    bool allValid = true;

    for (final element in replyMessage.payload!.segmentProfiles) {
      if (element.status == .invalid) {
        await _sferaDatabaseRepository.saveSegmentProfile(element);
      } else {
        allValid = false;
      }
    }

    if (!allValid) {
      _log.info('Received invalid local regulation SegmentProfiles, aborting...');
      _taskCompletedCallback(this, null);
    }

    final finished = _segementsToFetch == segmentProfileCount || segmentProfileCount != 0;
    if (finished) {
      _taskCompletedCallback(this, null);
    } else {
      execute(_taskCompletedCallback, _taskFailedCallback);
    }

    return true;
  }

  Future<void> _requestLocalRegulations() async {
    final missingSp = await _findMissingSegmentProfiles();
    if (missingSp.isEmpty) {
      _log.info('No missing local regulations found...');
      _taskCompletedCallback(this, true);
      return;
    }

    _segementsToFetch = missingSp.length;

    final List<SpRequestDto> spRequests = [];
    for (final sp in missingSp) {
      spRequests.add(
        SpRequestDto.create(
          id: sp,
          versionMajor: localRegulationVersionMajor,
          versionMinor: localRegulationVersionMinor,
          spZone: SpZoneDto.createLocalRegulationZone(),
        ),
      );
    }

    final sferaB2gRequestMessage = SferaB2gRequestMessageDto.create(
      _sferaRepo.messageHeader(sender: otnId.company),
      b2gRequest: B2gRequestDto.createSPRequest(spRequests),
    );
    _log.info('Sending local regulations segment profiles request...');

    startTimeout(_taskFailedCallback);
    final sferaTrain = Format.sferaTrain(otnId.operationalTrainNumber, otnId.startDate);
    _mqttService.publishMessage(otnId.company, sferaTrain, sferaB2gRequestMessage.buildDocument().toString());
  }

  Future<List<String>> _findMissingSegmentProfiles() async {
    final missingSps = <String>[];

    final locale = AppLocale.resolvedLocale();
    for (final segmentId in servicePoints.expand((sp) => sp.localRegulationSegmentIds).toSet()) {
      final languageSpecificSegmentId = '${segmentId}_$locale';

      final existingProfile = await _sferaDatabaseRepository.findSegmentProfile(
        languageSpecificSegmentId,
        localRegulationVersionMajor,
        localRegulationVersionMinor,
      );
      if (existingProfile == null) {
        missingSps.add(languageSpecificSegmentId);
      }
    }

    return missingSps;
  }
}
