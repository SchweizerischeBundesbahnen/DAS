import 'package:logging/logging.dart';
import 'package:sfera/src/data/api/event/sfera_event_message_handler.dart';
import 'package:sfera/src/data/dto/enums/jp_status_dto.dart';
import 'package:sfera/src/data/dto/journey_profile_dto.dart';
import 'package:sfera/src/data/dto/segment_profile_list_dto.dart';
import 'package:sfera/src/data/dto/sfera_g2b_event_message_dto.dart';
import 'package:sfera/src/data/local/sfera_local_database_service.dart';

final _log = Logger('JourneyProfileEventHandler');

typedef CurrentJourneyProfileFunction = JourneyProfileDto? Function();

class JourneyProfileEventHandler(
  super.onMessageHandled,
  final SferaLocalDatabaseService _sferaDatabaseRepository,
  final CurrentJourneyProfileFunction _currentJourneyProfile,
) extends SferaEventMessageHandler<JourneyProfileDto> {
  @override
  Future<bool> handleMessage(SferaG2bEventMessageDto eventMessage) async {
    if (eventMessage.payload == null || eventMessage.payload!.journeyProfiles.isEmpty) {
      return false;
    }

    if (eventMessage.payload!.journeyProfiles.length > 1) {
      _log.warning('Received more then 1 journey profile which is not supported, using first one provided');
    }

    final updatedJourneyProfile = eventMessage.payload!.journeyProfiles.first;
    final status = updatedJourneyProfile.status;
    switch (status) {
      case JpStatusDto.invalid:
      case JpStatusDto.unavailable:
        return true;
      case JpStatusDto.update:
        final currentJourneyProfile = _currentJourneyProfile();
        if (currentJourneyProfile == null) {
          _log.info('Received update for journey profile, but no current journey profile exists');
          return false;
        } else {
          _log.info('Received update for journey profile, merging it with the current journey profile');
          final mergedJourneyProfile = _mergeJourneyProfile(currentJourneyProfile, updatedJourneyProfile);
          await _sferaDatabaseRepository.saveJourneyProfile(mergedJourneyProfile);
          onMessageHandled(this, mergedJourneyProfile);
          return true;
        }
      case JpStatusDto.overwrite:
      case JpStatusDto.valid:
        _log.info('Received ${status.name.toUpperCase()} journey profile, saving it');
        await _sferaDatabaseRepository.saveJourneyProfile(updatedJourneyProfile);
        onMessageHandled(this, updatedJourneyProfile);
        return true;
    }
  }

  /// Will merge the current journey profile with the updated one, by keeping all segment profile references
  /// from the current journey profile until the first segment profile reference from the updated journey profile
  /// is found, and then adding all segment profile references from the updated journey profile.
  JourneyProfileDto _mergeJourneyProfile(
    JourneyProfileDto currentJourneyProfile,
    JourneyProfileDto updatedJourneyProfile,
  ) {
    final firstUpdatedSegment = updatedJourneyProfile.segmentProfileReferences.first;

    final mergedSegmentProfileReferences = <SegmentProfileReferenceDto>[];
    for (final segmentRef in currentJourneyProfile.segmentProfileReferences) {
      if (segmentRef.spId == firstUpdatedSegment.spId &&
          segmentRef.versionMajor == firstUpdatedSegment.versionMajor &&
          segmentRef.versionMinor == firstUpdatedSegment.versionMinor) {
        break;
      }
      mergedSegmentProfileReferences.add(segmentRef);
    }

    mergedSegmentProfileReferences.addAll(updatedJourneyProfile.segmentProfileReferences);

    return JourneyProfileDto.create(
      version: updatedJourneyProfile.version,
      trainIdentification: updatedJourneyProfile.trainIdentification,
      segmentProfileReferences: mergedSegmentProfileReferences,
      // TODO: Check with TMS how GeneralJPInformation merging should be done, or if they will provide everything
      generalJpInformation: updatedJourneyProfile.generalJpInformation,
    );
  }
}
