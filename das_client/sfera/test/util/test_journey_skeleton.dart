import 'package:sfera/src/data/dto/g2b_event_payload_dto.dart';
import 'package:sfera/src/data/dto/journey_profile_dto.dart';
import 'package:sfera/src/data/dto/segment_profile_dto.dart';
import 'package:sfera/src/data/dto/train_characteristics_dto.dart';

class TestJourneySkeleton {
  const TestJourneySkeleton({
    required this.journeyName,
    required this.journeyProfile,
    required this.segmentProfiles,
    required this.trainCharacteristics,
    this.journeyEvent,
  });

  final String journeyName;
  final JourneyProfileDto journeyProfile;
  final List<SegmentProfileDto> segmentProfiles;
  final List<TrainCharacteristicsDto> trainCharacteristics;
  final TestJourneyEvent? journeyEvent;

  bool validate() =>
      journeyProfile.validate() &&
      segmentProfiles.every((sP) => sP.validate()) &&
      trainCharacteristics.every((tC) => tC.validate()) &&
      (journeyEvent?.payload.validate() ?? true);
}

class TestJourneyEvent {
  const TestJourneyEvent({
    required this.name,
    required this.payload,
  });

  final String name;
  final G2bEventPayloadDto payload;
}
