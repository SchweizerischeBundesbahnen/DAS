import 'package:das_client/sfera/src/model/related_train_information.dart';
import 'package:das_client/sfera/src/model/sfera_g2b_event_message.dart';
import 'package:das_client/sfera/src/service/event/sfera_event_message_handler.dart';
import 'package:fimber/fimber.dart';

class RelatedTrainInformationEventHandler extends SferaEventMessageHandler<RelatedTrainInformation> {
  RelatedTrainInformationEventHandler(super.onMessageHandled);

  @override
  Future<bool> handleMessage(SferaG2bEventMessage eventMessage) async {
    if (eventMessage.payload == null || eventMessage.payload!.relatedTrainInformation == null) {
      return false;
    }

    Fimber.i('Received new related train information...');
    onMessageHandled(this, eventMessage.payload!.relatedTrainInformation!);
    return true;
  }
}
