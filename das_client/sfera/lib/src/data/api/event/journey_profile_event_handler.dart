import 'package:logging/logging.dart';
import 'package:sfera/src/data/api/event/sfera_event_message_handler.dart';
import 'package:sfera/src/data/dto/journey_profile_dto.dart';
import 'package:sfera/src/data/dto/sfera_g2b_event_message_dto.dart';
import 'package:sfera/src/data/local/sfera_local_database_service.dart';

final _log = Logger('JourneyProfileEventHandler');

class JourneyProfileEventHandler extends SferaEventMessageHandler<JourneyProfileDto> {
  final SferaLocalDatabaseService _sferaDatabaseRepository;

  JourneyProfileEventHandler(super.onMessageHandled, this._sferaDatabaseRepository);

  @override
  Future<bool> handleMessage(SferaG2bEventMessageDto eventMessage) async {
    if (eventMessage.payload == null || eventMessage.payload!.journeyProfiles.isEmpty) {
      return false;
    }

    _log.info('Updating journey profiles...');
    for (final journeyProfile in eventMessage.payload!.journeyProfiles) {
      await _sferaDatabaseRepository.saveJourneyProfile(journeyProfile);
    }

    if (eventMessage.payload!.journeyProfiles.length > 1) {
      _log.warning('Received more then 1 journey profile which is not supported, using first one provided');
    }

    onMessageHandled(this, eventMessage.payload!.journeyProfiles.first);
    return true;
  }
}
