import 'package:app/sfera/src/model/das_operating_modes_supported.dart';
import 'package:app/sfera/src/model/enums/das_architecture.dart';
import 'package:app/sfera/src/model/enums/das_connectivity.dart';
import 'package:app/sfera/src/model/enums/das_driving_mode.dart';
import 'package:app/sfera/src/model/enums/related_train_request_type.dart';
import 'package:app/sfera/src/model/handshake_request.dart';
import 'package:app/sfera/src/model/otn_id.dart';
import 'package:app/sfera/src/model/sfera_b2g_request_message.dart';
import 'package:app/sfera/src/model/sfera_g2b_reply_message.dart';
import 'package:app/sfera/src/service/remote/sfera_service.dart';
import 'package:app/sfera/src/service/remote/task/sfera_task.dart';
import 'package:app/util/error_code.dart';
import 'package:fimber/fimber.dart';
import 'package:mqtt_x/component.dart';

class HandshakeTask extends SferaTask {
  HandshakeTask({required MqttService mqttService, required this.otnId, required this.dasDrivingMode, super.timeout})
      : _mqttService = mqttService;

  final MqttService _mqttService;
  final OtnId otnId;
  final DasDrivingMode dasDrivingMode;

  late TaskCompleted _taskCompletedCallback;
  late TaskFailed _taskFailedCallback;

  @override
  Future<void> execute(TaskCompleted onCompleted, TaskFailed onFailed) async {
    startTimeout(onFailed);
    _taskCompletedCallback = onCompleted;
    _taskFailedCallback = onFailed;

    await _sendHandshakeRequest();
  }

  Future<void> _sendHandshakeRequest() async {
    final sferaTrain = SferaService.sferaTrain(otnId.operationalTrainNumber, otnId.startDate);

    Fimber.i('Sending handshake request for company=${otnId.company} train=$sferaTrain');
    final operationMode = DasOperatingModesSupported.create(
        dasDrivingMode, DasArchitecture.boardAdviceCalculation, DasConnectivity.connected);
    final handshakeRequest = HandshakeRequest.create(
      [operationMode],
      relatedTrainRequestType: RelatedTrainRequestType.ownTrainAndRelatedTrains,
      statusReportsEnabled: false,
    );

    final messageHeader = await SferaService.messageHeader(sender: otnId.company);
    final sferaB2gRequestMessage = SferaB2gRequestMessage.create(messageHeader, handshakeRequest: handshakeRequest);
    final success =
        _mqttService.publishMessage(otnId.company, sferaTrain, sferaB2gRequestMessage.buildDocument().toString());

    if (!success) {
      _taskFailedCallback(this, ErrorCode.connectionFailed);
    }
  }

  @override
  Future<bool> handleMessage(SferaG2bReplyMessage replyMessage) async {
    if (replyMessage.handshakeAcknowledgement != null) {
      stopTimeout();
      Fimber.i('Received handshake acknowledgment');
      _taskCompletedCallback(this, null);
      return true;
    } else if (replyMessage.handshakeReject != null) {
      stopTimeout();
      Fimber.w(
          'Received handshake reject with reason=${replyMessage.handshakeReject?.handshakeRejectReason?.toString()}');
      _taskFailedCallback(this, ErrorCode.sferaHandshakeRejected);
      _mqttService.disconnect();
      return true;
    } else {
      Fimber.w('Ignoring response because is does not contain handshake');
      return false;
    }
  }
}
