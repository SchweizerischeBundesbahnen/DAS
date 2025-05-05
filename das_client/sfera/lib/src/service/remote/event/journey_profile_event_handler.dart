import 'package:sfera/src/db/repo/sfera_database_repository.dart';
import 'package:sfera/src/model/journey_profile.dart';
import 'package:sfera/src/model/sfera_g2b_event_message.dart';
import 'package:sfera/src/service/remote/event/sfera_event_message_handler.dart';
import 'package:fimber/fimber.dart';

class JourneyProfileEventHandler extends SferaEventMessageHandler<JourneyProfile> {
  final SferaDatabaseRepository _sferaDatabaseRepository;

  JourneyProfileEventHandler(super.onMessageHandled, this._sferaDatabaseRepository);

  @override
  Future<bool> handleMessage(SferaG2bEventMessage eventMessage) async {
    if (eventMessage.payload == null || eventMessage.payload!.journeyProfiles.isEmpty) {
      return false;
    }

    Fimber.i('Updating journey profiles...');
    for (final journeyProfile in eventMessage.payload!.journeyProfiles) {
      await _sferaDatabaseRepository.saveJourneyProfile(journeyProfile);
    }

    if (eventMessage.payload!.journeyProfiles.length > 1) {
      Fimber.w('Received more then 1 journey profile which is not supported, using first one provided');
    }

    onMessageHandled(this, eventMessage.payload!.journeyProfiles.first);
    return true;
  }
}
