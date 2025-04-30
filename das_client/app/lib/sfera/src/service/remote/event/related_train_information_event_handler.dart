import 'package:app/sfera/src/model/related_train_information.dart';
import 'package:app/sfera/src/model/sfera_g2b_event_message.dart';
import 'package:app/sfera/src/service/remote/event/sfera_event_message_handler.dart';
import 'package:fimber/fimber.dart';

class RelatedTrainInformationEventHandler extends SferaEventMessageHandler<RelatedTrainInformation> {
  RelatedTrainInformationEventHandler(super.onMessageHandled);

  @override
  Future<bool> handleMessage(SferaG2bEventMessage eventMessage) async {
    if (eventMessage.payload == null || eventMessage.payload!.relatedTrainInformation == null) {
      return false;
    }

    final delay = eventMessage.payload!.relatedTrainInformation?.ownTrain.trainLocationInformation.delay.delay;
    Fimber.i('Received new related train information... delay=$delay');
    onMessageHandled(this, eventMessage.payload!.relatedTrainInformation!);
    return true;
  }
}
