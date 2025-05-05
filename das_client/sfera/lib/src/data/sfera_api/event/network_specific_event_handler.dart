import 'package:sfera/src/data/dto/network_specific_event.dart';
import 'package:sfera/src/data/dto/sfera_g2b_event_message.dart';
import 'package:sfera/src/data/sfera_api/event/sfera_event_message_handler.dart';
import 'package:fimber/fimber.dart';

class NetworkSpecificEventHandler extends SferaEventMessageHandler<NetworkSpecificEvent> {
  NetworkSpecificEventHandler(super.onMessageHandled);

  @override
  Future<bool> handleMessage(SferaG2bEventMessage eventMessage) async {
    if (eventMessage.payload == null || eventMessage.payload!.networkSpecificEvent == null) {
      return false;
    }

    Fimber.i('Received new network specific event: ${eventMessage.payload!.networkSpecificEvent!}');
    onMessageHandled(this, eventMessage.payload!.networkSpecificEvent!);
    return true;
  }
}
