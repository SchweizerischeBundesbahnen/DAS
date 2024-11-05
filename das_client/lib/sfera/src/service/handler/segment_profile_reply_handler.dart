import 'package:das_client/sfera/src/model/sfera_g2b_reply_message.dart';
import 'package:das_client/sfera/src/repo/sfera_repository.dart';
import 'package:das_client/sfera/src/service/handler/sfera_message_handler.dart';
import 'package:fimber/fimber.dart';

class SegmentProfileReplyHandler implements SferaMessageHandler {
  final SferaRepository _sferaRepository;
  SegmentProfileReplyHandler(this._sferaRepository);

  @override
  Future<bool> handleMessage(SferaG2bReplyMessage message) async {
    if (message.payload == null || message.payload!.segmentProfiles.isEmpty) {
      return false;
    }
    
    Fimber.i('Updating segment profiles...');
    for (var segmentProfile in message.payload!.segmentProfiles) {
      await _sferaRepository.saveSegmentProfile(segmentProfile);
    }

    return true;
  }
}
