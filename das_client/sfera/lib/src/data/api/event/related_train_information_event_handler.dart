import 'package:logging/logging.dart';
import 'package:sfera/src/data/api/event/sfera_event_message_handler.dart';
import 'package:sfera/src/data/dto/related_train_information_dto.dart';
import 'package:sfera/src/data/dto/sfera_g2b_event_message_dto.dart';

final _log = Logger('RelatedTrainInformationEventHandler');

class RelatedTrainInformationEventHandler extends SferaEventMessageHandler<RelatedTrainInformationDto> {
  RelatedTrainInformationEventHandler(super.onMessageHandled);

  @override
  Future<bool> handleMessage(SferaG2bEventMessageDto eventMessage) async {
    if (eventMessage.payload == null || eventMessage.payload!.relatedTrainInformation == null) {
      return false;
    }

    final delay = eventMessage.payload!.relatedTrainInformation?.ownTrain.trainLocationInformation.delay?.delay;
    _log.info('Received new related train information... delay=$delay');
    onMessageHandled(this, eventMessage.payload!.relatedTrainInformation!);
    return true;
  }
}
