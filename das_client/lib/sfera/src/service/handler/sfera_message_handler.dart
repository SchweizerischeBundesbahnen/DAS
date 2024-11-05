import 'package:das_client/sfera/src/model/sfera_g2b_reply_message.dart';

abstract class SferaMessageHandler {
  Future<bool> handleMessage(SferaG2bReplyMessage replyMessage);
}
