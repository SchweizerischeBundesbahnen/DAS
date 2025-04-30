import 'package:app/sfera/src/model/network_specific_event.dart';
import 'package:app/sfera/src/model/sfera_g2b_event_message.dart';
import 'package:app/sfera/src/service/remote/event/sfera_event_message_handler.dart';
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
