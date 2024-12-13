import 'package:das_client/mqtt/mqtt_component.dart';
import 'package:das_client/sfera/src/model/b2g_request.dart';
import 'package:das_client/sfera/src/model/journey_profile.dart';
import 'package:das_client/sfera/src/model/otn_id.dart';
import 'package:das_client/sfera/src/model/sfera_b2g_request_message.dart';
import 'package:das_client/sfera/src/model/sfera_g2b_reply_message.dart';
import 'package:das_client/sfera/src/model/tc_request.dart';
import 'package:das_client/sfera/src/model/train_characteristics.dart';
import 'package:das_client/sfera/src/model/train_characteristics_ref.dart';
import 'package:das_client/sfera/src/model/train_identification.dart';
import 'package:das_client/sfera/src/repo/sfera_repository.dart';
import 'package:das_client/sfera/src/service/sfera_service.dart';
import 'package:das_client/sfera/src/service/task/sfera_task.dart';
import 'package:fimber/fimber.dart';

class RequestTrainCharacteristicsTask extends SferaTask<List<TrainCharacteristics>> {
  RequestTrainCharacteristicsTask(
      {required MqttService mqttService,
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

  late TaskCompleted<List<TrainCharacteristics>> _taskCompletedCallback;
  late TaskFailed _taskFailedCallback;

  @override
  Future<void> execute(TaskCompleted<List<TrainCharacteristics>> onCompleted, TaskFailed onFailed) async {
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

    final List<TcRequest> tcRequests = [];
    for (final missingTrainRef in missingTrainCharacteristics) {
      tcRequests.add(TcRequest.create(
          id: missingTrainRef.tcId,
          versionMajor: missingTrainRef.versionMajor,
          versionMinor: missingTrainRef.versionMinor,
          ruId: missingTrainRef.ruId));
    }

    final trainIdentification = TrainIdentification.create(otnId: otnId);
    final sferaB2gRequestMessage = SferaB2gRequestMessage.create(
        await SferaService.messageHeader(trainIdentification: trainIdentification, sender: otnId.company),
        b2gRequest: B2gRequest.createTCRequest(tcRequests));
    Fimber.i('Sending train characteristics request...');

    startTimeout(_taskFailedCallback);
    _mqttService.publishMessage(otnId.company, SferaService.sferaTrain(otnId.operationalTrainNumber, otnId.startDate),
        sferaB2gRequestMessage.buildDocument().toString());
  }

  Future<Set<TrainCharacteristicsRef>> findMissingTrainCharacteristics() async {
    final missingTrainCharacteristics = <TrainCharacteristicsRef>{};

    for (final trainRef in journeyProfile.trainCharactericsRefSet) {
      final existingTrainCharacteristic =
          await _sferaRepository.findTrainCharacteristics(trainRef.tcId, trainRef.versionMajor, trainRef.versionMinor);
      if (existingTrainCharacteristic == null) {
        missingTrainCharacteristics.add(trainRef);
      }
    }

    return missingTrainCharacteristics;
  }

  @override
  Future<bool> handleMessage(SferaG2bReplyMessage replyMessage) async {
    if (replyMessage.payload != null && replyMessage.payload!.trainCharacteristics.isNotEmpty) {
      stopTimeout();
      Fimber.i(
        'Received G2bReplyPayload response with ${replyMessage.payload!.trainCharacteristics.length} TrainCharacteristics...',
      );

      for (final element in replyMessage.payload!.trainCharacteristics) {
        await _sferaRepository.saveTrainCharacteristics(element);
      }

      _taskCompletedCallback(this, replyMessage.payload!.trainCharacteristics.toList());

      return true;
    }
    return false;
  }
}
