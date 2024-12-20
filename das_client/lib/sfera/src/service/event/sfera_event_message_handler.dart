import 'package:das_client/sfera/src/model/sfera_g2b_event_message.dart';

typedef MessageHandled<T> = void Function(SferaEventMessageHandler handler, T data);

abstract class SferaEventMessageHandler<T> {
  SferaEventMessageHandler(this.onMessageHandled);

  final MessageHandled<T> onMessageHandled;

  Future<bool> handleMessage(SferaG2bEventMessage eventMessage);
}
