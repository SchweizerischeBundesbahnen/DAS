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
  HandshakeTask({required MqttService mqttService, required this.otnId}) : _mqttService = mqttService;

  final MqttService _mqttService;
  final OtnId otnId;

  late TaskCompleted _taskCompletedCallback;
  late TaskFailed _taskFailedCallback;

  @override
  void execute(TaskCompleted onCompleted, TaskFailed onFailed) {
    _taskCompletedCallback = onCompleted;
    _taskFailedCallback = onFailed;

    _sendHandshakeRequest();
  }

  void _sendHandshakeRequest() async {
    var sferaTrain = SferaService.sferaTrain(otnId.operationalTrainNumber, otnId.startDate);

    Fimber.i("Sending handshake request for company=${otnId.company} train=$sferaTrain");
    var handshakeRequest = HandshakeRequest.create([
      DasOperatingModesSupported.create(
          DasDrivingMode.goa1, DasArchitecture.boardAdviceCalculation, DasConnectivity.connected),
    ], relatedTrainRequestType: RelatedTrainRequestType.ownTrainAndRelatedTrains, statusReportsEnabled: true);

    var sferaB2gRequestMessage =
        SferaB2gRequestMessage.create(await SferaService.messageHeader(), handshakeRequest: handshakeRequest);
    _mqttService.publishMessage(otnId.company, sferaTrain, sferaB2gRequestMessage.buildDocument().toString());
  }

  @override
  Future<bool> handleMessage(SferaG2bReplyMessage message) async {
    if (message.handshakeAcknowledgement != null) {
      Fimber.i("Received handshake acknowledgment");
      _taskCompletedCallback(this, null);
      return true;
    } else if (message.handshakeReject != null) {
      Fimber.w(
          "Received handshake reject with reason=${message.handshakeReject?.handshakeRejectReason?.toString()}");
      _taskFailedCallback(this, ErrorCode.sferaHandshakeRejected);
      _mqttService.disconnect();
      return true;
    } else {
      Fimber.w("Ignoring response because is does not contain handshake");
      return false;
    }
  }
}
