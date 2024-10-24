import 'package:das_client/model/sfera/das_operating_modes_supported.dart';
import 'package:das_client/model/sfera/enums/das_architecture.dart';
import 'package:das_client/model/sfera/enums/das_connectivity.dart';
import 'package:das_client/model/sfera/enums/das_driving_mode.dart';
import 'package:das_client/model/sfera/enums/related_train_request_type.dart';
import 'package:das_client/model/sfera/handshake_request.dart';
import 'package:das_client/model/sfera/otn_id.dart';
import 'package:das_client/model/sfera/sfera_b2g_request_message.dart';
import 'package:das_client/model/sfera/sfera_g2b_reply_message.dart';
import 'package:das_client/service/mqtt/mqtt_service.dart';
import 'package:das_client/service/sfera/sfera_service.dart';
import 'package:das_client/service/sfera/task/sfera_task.dart';
import 'package:das_client/util/error_code.dart';
import 'package:fimber/fimber.dart';

class HandshakeTask extends SferaTask {
  HandshakeTask({required MqttService mqttService, required this.otnId, super.timeout})
      : _mqttService = mqttService;

  final MqttService _mqttService;
  final OtnId otnId;

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
    var sferaTrain = SferaService.sferaTrain(otnId.operationalTrainNumber, otnId.startDate);

    Fimber.i("Sending handshake request for company=${otnId.company} train=$sferaTrain");
    var handshakeRequest = HandshakeRequest.create([
      DasOperatingModesSupported.create(
          DasDrivingMode.readOnly, DasArchitecture.boardAdviceCalculation, DasConnectivity.connected),
    ], relatedTrainRequestType: RelatedTrainRequestType.ownTrainAndRelatedTrains, statusReportsEnabled: false);

    var sferaB2gRequestMessage =
        SferaB2gRequestMessage.create(await SferaService.messageHeader(), handshakeRequest: handshakeRequest);
    var success =
        _mqttService.publishMessage(otnId.company, sferaTrain, sferaB2gRequestMessage.buildDocument().toString());

    if (!success) {
      _taskFailedCallback(this, ErrorCode.connectionFailed);
    }
  }

  @override
  Future<bool> handleMessage(SferaG2bReplyMessage message) async {
    if (message.handshakeAcknowledgement != null) {
      stopTimeout();
      Fimber.i("Received handshake acknowledgment");
      _taskCompletedCallback(this, null);
      return true;
    } else if (message.handshakeReject != null) {
      stopTimeout();
      Fimber.w("Received handshake reject with reason=${message.handshakeReject?.handshakeRejectReason?.toString()}");
      _taskFailedCallback(this, ErrorCode.sferaHandshakeRejected);
      _mqttService.disconnect();
      return true;
    } else {
      Fimber.w("Ignoring response because is does not contain handshake");
      return false;
    }
  }
}
