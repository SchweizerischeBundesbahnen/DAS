import 'package:das_client/model/sfera/sfera_g2b_reply_message.dart';

abstract class SferaMessageHandler {
  Future<bool> handleMessage(SferaG2bReplyMessage replyMessage);
}
