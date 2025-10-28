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
    required this.journeyEvents,
  });

  final String journeyName;
  final JourneyProfileDto journeyProfile;
  final List<SegmentProfileDto> segmentProfiles;
  final List<TrainCharacteristicsDto> trainCharacteristics;
  final List<TestJourneyEvent> journeyEvents;
}

class TestJourneyEvent {
  const TestJourneyEvent({
    required this.name,
    required this.payload,
  });

  final String name;
  final G2bEventPayloadDto payload;
}
