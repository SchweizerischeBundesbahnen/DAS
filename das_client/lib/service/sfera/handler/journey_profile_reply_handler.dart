import 'package:das_client/model/sfera/sfera_g2b_reply_message.dart';
import 'package:das_client/repo/sfera_repository.dart';
import 'package:das_client/service/sfera/handler/sfera_message_handler.dart';
import 'package:fimber/fimber.dart';

class JourneyProfileReplyHandler implements SferaMessageHandler {
  final SferaRepository _sferaRepository;
  JourneyProfileReplyHandler(this._sferaRepository);

  @override
  Future<bool> handleMessage(SferaG2bReplyMessage message) async {
    if (message.payload == null || message.payload!.journeyProfiles.isEmpty) {
      return false;
    }

    Fimber.i("Updating journey profiles...");
    for (var journeyProfile in message.payload!.journeyProfiles) {
      await _sferaRepository.saveJourneyProfile(journeyProfile);
    }

    return true;
  }
}
