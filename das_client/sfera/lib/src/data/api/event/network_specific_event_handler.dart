import 'package:fimber/fimber.dart';
import 'package:sfera/src/data/api/event/sfera_event_message_handler.dart';
import 'package:sfera/src/data/dto/network_specific_event_dto.dart';
import 'package:sfera/src/data/dto/sfera_g2b_event_message_dto.dart';

class NetworkSpecificEventHandler extends SferaEventMessageHandler<NetworkSpecificEventDto> {
  NetworkSpecificEventHandler(super.onMessageHandled);

  @override
  Future<bool> handleMessage(SferaG2bEventMessageDto eventMessage) async {
    if (eventMessage.payload == null || eventMessage.payload!.networkSpecificEvent == null) {
      return false;
    }

    Fimber.i('Received new network specific event: ${eventMessage.payload!.networkSpecificEvent!}');
    onMessageHandled(this, eventMessage.payload!.networkSpecificEvent!);
    return true;
  }
}
