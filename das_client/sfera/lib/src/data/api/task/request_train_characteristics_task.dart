import 'package:mqtt/component.dart';
import 'package:sfera/component.dart';
import 'package:sfera/src/data/api/task/sfera_task.dart';

import 'package:sfera/src/data/dto/b2g_request_dto.dart';
import 'package:sfera/src/data/dto/journey_profile_dto.dart';
import 'package:sfera/src/data/dto/sfera_b2g_request_message_dto.dart';
import 'package:sfera/src/data/dto/sfera_g2b_reply_message_dto.dart';
import 'package:sfera/src/data/dto/tc_request_dto.dart';
import 'package:sfera/src/data/dto/train_characteristics_dto.dart';
import 'package:sfera/src/data/dto/train_characteristics_ref_dto.dart';
import 'package:fimber/fimber.dart';

class RequestTrainCharacteristicsTask extends SferaTask<List<TrainCharacteristicsDto>> {
  RequestTrainCharacteristicsTask({
    required MqttService mqttService,
    required SferaDatabaseRepository sferaDatabaseRepository,
    required this.otnId,
    required this.journeyProfile,
    super.timeout,
  })  : _mqttService = mqttService,
        _sferaDatabaseRepository = sferaDatabaseRepository;

  final MqttService _mqttService;
  final OtnIdDto otnId;
  final SferaDatabaseRepository _sferaDatabaseRepository;
  final JourneyProfileDto journeyProfile;

  late TaskCompleted<List<TrainCharacteristicsDto>> _taskCompletedCallback;
  late TaskFailed _taskFailedCallback;

  @override
  Future<void> execute(TaskCompleted<List<TrainCharacteristicsDto>> onCompleted, TaskFailed onFailed) async {
    _taskCompletedCallback = onCompleted;
    _taskFailedCallback = onFailed;

    await _requestSegmentProfiles();
  }

  Future<void> _requestSegmentProfiles() async {
    final missingTrainCharacteristics = await findMissingTrainCharacteristics();
    if (missingTrainCharacteristics.isEmpty) {
      Fimber.i('No missing train characteristics found...');
      _taskCompletedCallback(this, []);
      return;
    }

    final List<TcRequestDto> tcRequests = [];
    for (final missingTrainRef in missingTrainCharacteristics) {
      tcRequests.add(TcRequestDto.create(
          id: missingTrainRef.tcId,
          versionMajor: missingTrainRef.versionMajor,
          versionMinor: missingTrainRef.versionMinor,
          ruId: missingTrainRef.ruId));
    }

    final sferaB2gRequestMessage = SferaB2gRequestMessageDto.create(
        await SferaService.messageHeader(sender: otnId.company),
        b2gRequest: B2gRequestDto.createTCRequest(tcRequests));
    Fimber.i('Sending train characteristics request...');

    startTimeout(_taskFailedCallback);
    _mqttService.publishMessage(otnId.company, SferaService.sferaTrain(otnId.operationalTrainNumber, otnId.startDate),
        sferaB2gRequestMessage.buildDocument().toString());
  }

  Future<Set<TrainCharacteristicsRefDto>> findMissingTrainCharacteristics() async {
    final missingTrainCharacteristics = <TrainCharacteristicsRefDto>{};

    for (final trainRef in journeyProfile.trainCharacteristicsRefSet) {
      final existingTrainCharacteristic = await _sferaDatabaseRepository.findTrainCharacteristics(
          trainRef.tcId, trainRef.versionMajor, trainRef.versionMinor);
      if (existingTrainCharacteristic == null) {
        missingTrainCharacteristics.add(trainRef);
      }
    }

    return missingTrainCharacteristics;
  }

  @override
  Future<bool> handleMessage(SferaG2bReplyMessageDto replyMessage) async {
    if (replyMessage.payload == null || replyMessage.payload!.trainCharacteristics.isEmpty) {
      return false;
    }

    stopTimeout();
    Fimber.i(
      'Received G2bReplyPayload response with ${replyMessage.payload!.trainCharacteristics.length} TrainCharacteristics...',
    );

    for (final element in replyMessage.payload!.trainCharacteristics) {
      await _sferaDatabaseRepository.saveTrainCharacteristics(element);
    }

    _taskCompletedCallback(this, replyMessage.payload!.trainCharacteristics.toList());

    return true;
  }
}
