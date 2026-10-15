import 'package:logging/logging.dart';
import 'package:mqtt/component.dart';
import 'package:sfera/component.dart';
import 'package:sfera/src/data/api/task/sfera_task.dart';
import 'package:sfera/src/data/dto/b2g_request_dto.dart';
import 'package:sfera/src/data/dto/g2b_error.dart';
import 'package:sfera/src/data/dto/otn_id_dto.dart';
import 'package:sfera/src/data/dto/related_train_information_request_dto.dart';
import 'package:sfera/src/data/dto/sfera_b2g_request_message_dto.dart';
import 'package:sfera/src/data/dto/sfera_g2b_reply_message_dto.dart';
import 'package:sfera/src/data/dto/train_identification_dto.dart';
import 'package:sfera/src/data/format.dart';
import 'package:sfera/src/model/otn_id.dart';

final _log = Logger('RequestRelatedTrainInformationTask');

class RequestRelatedTrainInformationTask({
  required final MqttService _mqttService,
  required final SferaRepository _sferaRepo,
  required final OtnId otnId,
  super.timeout,
}) extends SferaTask<dynamic> {
  late TaskCompleted<dynamic> _taskCompletedCallback;
  late TaskFailed _taskFailedCallback;

  @override
  Future<void> execute(TaskCompleted<dynamic> onCompleted, TaskFailed onFailed) async {
    _taskCompletedCallback = onCompleted;
    _taskFailedCallback = onFailed;

    await _requestRelatedTrainInformation();
    startTimeout(_taskFailedCallback);
  }

  Future<void> _requestRelatedTrainInformation() async {
    final otnIdDto = OtnIdDto.create(otnId.company, otnId.operationalTrainNumber, otnId.startDate);
    final trainIdentification = TrainIdentificationDto.create(otnId: otnIdDto);
    final relatedTrainInformationRequest = RelatedTrainInformationRequestDto.create(trainIdentification);

    _log.info('Sending related train information request...');
    final sferaB2gRequestMessage = SferaB2gRequestMessageDto.create(
      _sferaRepo.messageHeader(sender: otnId.company),
      b2gRequest: B2gRequestDto.createRelatedTrainInformationRequest(relatedTrainInformationRequest),
    );
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
    if (payload == null || payload.relatedTrainInformation == null) {
      return false;
    }

    stopTimeout();
    _log.info('Received RelatedTrainInformation...');

    _taskCompletedCallback(this, payload.relatedTrainInformation);
    return true;
  }
}
