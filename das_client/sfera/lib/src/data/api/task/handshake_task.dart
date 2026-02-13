import 'package:logging/logging.dart';
import 'package:mqtt/component.dart';
import 'package:sfera/component.dart';
import 'package:sfera/src/data/api/task/sfera_task.dart';
import 'package:sfera/src/data/dto/das_operating_modes_supported_dto.dart';
import 'package:sfera/src/data/dto/enums/das_driving_mode_dto.dart';
import 'package:sfera/src/data/dto/g2b_error.dart';
import 'package:sfera/src/data/dto/handshake_request_dto.dart';
import 'package:sfera/src/data/dto/sfera_b2g_request_message_dto.dart';
import 'package:sfera/src/data/dto/sfera_g2b_reply_message_dto.dart';
import 'package:sfera/src/data/format.dart';
import 'package:sfera/src/model/otn_id.dart';

final _log = Logger('HandshakeTask');

class HandshakeTask extends SferaTask {
  HandshakeTask({
    required MqttService mqttService,
    required SferaRepo sferaRepo,
    required this.otnId,
    required this.dasDrivingMode,
    super.timeout,
  }) : _mqttService = mqttService,
       _sferaRepo = sferaRepo;

  final SferaRepo _sferaRepo;
  final MqttService _mqttService;
  final OtnId otnId;
  final DasDrivingModeDto dasDrivingMode;

  late TaskCompleted _taskCompletedCallback;
  late TaskFailed _taskFailedCallback;

  @override
  Future<void> execute(TaskCompleted onCompleted, TaskFailed onFailed) async {
    startTimeout(onFailed);
    _taskCompletedCallback = onCompleted;
    _taskFailedCallback = onFailed;

    _sendHandshakeRequest();
  }

  void _sendHandshakeRequest() {
    final sferaTrain = Format.sferaTrain(otnId.operationalTrainNumber, otnId.startDate);

    _log.info('Sending handshake request for company=${otnId.company} train=$sferaTrain');
    final operationMode = DasOperatingModesSupportedDto.create(dasDrivingMode, .boardAdviceCalculation, .connected);
    final handshakeRequest = HandshakeRequestDto.create(
      [operationMode],
      relatedTrainRequestType: .ownTrainAndRelatedTrains,
      statusReportsEnabled: false,
    );

    final messageHeader = _sferaRepo.messageHeader(sender: otnId.company);
    final sferaB2gRequestMessage = SferaB2gRequestMessageDto.create(messageHeader, handshakeRequest: handshakeRequest);
    final message = sferaB2gRequestMessage.buildDocument().toString();
    final success = _mqttService.publishMessage(otnId.company, sferaTrain, message);

    if (!success) {
      _taskFailedCallback(this, .connectionFailed());
    }
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

    if (replyMessage.handshakeAcknowledgement != null) {
      stopTimeout();
      _log.info('Received handshake acknowledgment');
      _taskCompletedCallback(this, null);
      return true;
    } else if (replyMessage.handshakeReject != null) {
      stopTimeout();
      _log.warning(
        'Received handshake reject with reason=${replyMessage.handshakeReject?.handshakeRejectReason?.toString()}',
      );
      _taskFailedCallback(this, .handshakeRejected());
      _mqttService.disconnect();
      return true;
    } else {
      _log.warning('Ignoring response because is does not contain handshake');
      return false;
    }
  }
}
