import 'package:logging/logging.dart';
import 'package:sfera/src/data/api/event/sfera_event_message_handler.dart';
import 'package:sfera/src/data/dto/network_specific_event_dto.dart';
import 'package:sfera/src/data/dto/sfera_g2b_event_message_dto.dart';

final _log = Logger('NetworkSpecificEventHandler');

class NetworkSpecificEventHandler extends SferaEventMessageHandler<NetworkSpecificEventDto> {
  NetworkSpecificEventHandler(super.onMessageHandled);

  @override
  Future<bool> handleMessage(SferaG2bEventMessageDto eventMessage) async {
    if (eventMessage.payload == null || eventMessage.payload!.networkSpecificEvent == null) {
      return false;
    }

    _log.info('Received new network specific event: ${eventMessage.payload!.networkSpecificEvent!}');
    onMessageHandled(this, eventMessage.payload!.networkSpecificEvent!);
    return true;
  }
}
