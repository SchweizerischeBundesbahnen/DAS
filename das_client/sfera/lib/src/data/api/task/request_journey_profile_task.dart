import 'package:logging/logging.dart';
import 'package:mqtt/component.dart';
import 'package:sfera/component.dart';
import 'package:sfera/src/data/api/task/sfera_task.dart';
import 'package:sfera/src/data/dto/b2g_request_dto.dart';
import 'package:sfera/src/data/dto/g2b_error.dart';
import 'package:sfera/src/data/dto/jp_request_dto.dart';
import 'package:sfera/src/data/dto/otn_id_dto.dart';
import 'package:sfera/src/data/dto/sfera_b2g_request_message_dto.dart';
import 'package:sfera/src/data/dto/sfera_g2b_reply_message_dto.dart';
import 'package:sfera/src/data/dto/train_identification_dto.dart';
import 'package:sfera/src/data/format.dart';
import 'package:sfera/src/data/local/sfera_local_database_service.dart';
import 'package:sfera/src/model/otn_id.dart';

final _log = Logger('RequestJourneyProfileTask');

class RequestJourneyProfileTask extends SferaTask<List<dynamic>> {
  RequestJourneyProfileTask({
    required MqttService mqttService,
    required SferaRepository sferaRepo,
    required SferaLocalDatabaseService sferaDatabaseRepository,
    required this.otnId,
    super.timeout,
  }) : _mqttService = mqttService,
       _sferaDatabaseRepository = sferaDatabaseRepository,
       _sferaRepo = sferaRepo;

  final MqttService _mqttService;
  final OtnId otnId;
  final SferaLocalDatabaseService _sferaDatabaseRepository;
  final SferaRepository _sferaRepo;

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
    final otnIdDto = OtnIdDto.create(otnId.company, otnId.operationalTrainNumber, otnId.startDate);
    final trainIdentification = TrainIdentificationDto.create(otnId: otnIdDto);
    final jpRequest = JpRequestDto.create(trainIdentification);

    final sferaB2gRequestMessage = SferaB2gRequestMessageDto.create(
      _sferaRepo.messageHeader(sender: otnId.company),
      b2gRequest: B2gRequestDto.createJPRequest(jpRequest),
    );
    _log.info('Sending journey profile request...');
    _mqttService.publishMessage(
      otnId.company,
      Format.sferaTrain(otnId.operationalTrainNumber, otnId.startDate),
      sferaB2gRequestMessage.buildDocument().toString(),
    );
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

    final payload = replyMessage.payload;
    if (payload == null || payload.journeyProfiles.isEmpty) {
      return false;
    }

    stopTimeout();
    final journeyProfile = payload.journeyProfiles.first;
    if (journeyProfile.status == .invalid || journeyProfile.status == .unavailable) {
      _log.warning('Received JourneyProfile with status=${journeyProfile.status}.');
      _taskFailedCallback(this, .jpUnavailable());
      return true;
    }

    _log.info(
      'Received G2bReplyPayload response with ${payload.journeyProfiles.length} JourneyProfiles, '
      '${payload.segmentProfiles.length} SegmentProfiles and '
      '${payload.trainCharacteristics.length} TrainCharacteristics...',
    );

    for (final element in payload.segmentProfiles) {
      await _sferaDatabaseRepository.saveSegmentProfile(element);
    }

    for (final trainCharacteristics in payload.trainCharacteristics) {
      await _sferaDatabaseRepository.saveTrainCharacteristics(trainCharacteristics);
    }

    for (final journeyProfile in payload.journeyProfiles) {
      await _sferaDatabaseRepository.saveJourneyProfile(journeyProfile);
    }

    final result = [];
    result.addAll(payload.journeyProfiles);
    result.addAll(payload.segmentProfiles);
    result.addAll(payload.trainCharacteristics);
    result.addAll(payload.relatedTrainInformation);

    _taskCompletedCallback(this, result);
    return true;
  }
}
