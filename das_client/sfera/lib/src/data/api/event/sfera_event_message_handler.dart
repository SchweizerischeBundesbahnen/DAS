import 'package:sfera/src/data/dto/sfera_g2b_event_message_dto.dart';

typedef MessageHandled<T> = void Function(SferaEventMessageHandler handler, T data);

abstract class SferaEventMessageHandler<T> {
  SferaEventMessageHandler(this.onMessageHandled);

  final MessageHandled<T> onMessageHandled;

  Future<bool> handleMessage(SferaG2bEventMessageDto eventMessage);
}
