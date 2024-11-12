import 'package:das_client/sfera/src/model/sfera_g2b_reply_message.dart';
import 'package:das_client/sfera/src/repo/sfera_repository.dart';
import 'package:das_client/sfera/src/service/handler/sfera_message_handler.dart';
import 'package:fimber/fimber.dart';

class JourneyProfileReplyHandler implements SferaMessageHandler {
  final SferaRepository _sferaRepository;
  JourneyProfileReplyHandler(this._sferaRepository);

  @override
  Future<bool> handleMessage(SferaG2bReplyMessage message) async {
    if (message.payload == null || message.payload!.journeyProfiles.isEmpty) {
      return false;
    }

    Fimber.i('Updating journey profiles...');
    for (final journeyProfile in message.payload!.journeyProfiles) {
      await _sferaRepository.saveJourneyProfile(journeyProfile);
    }

    return true;
  }
}
