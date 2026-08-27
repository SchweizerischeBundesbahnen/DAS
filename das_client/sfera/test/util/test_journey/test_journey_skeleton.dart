import 'package:sfera/src/data/dto/g2b_event_payload_dto.dart';
import 'package:sfera/src/data/dto/journey_profile_dto.dart';
import 'package:sfera/src/data/dto/segment_profile_dto.dart';
import 'package:sfera/src/data/dto/train_characteristics_dto.dart';
import 'package:sfera/src/data/mapper/sfera_model_mapper.dart';

import 'test_journey.dart';

class const TestJourneySkeleton({
  required final String journeyName,
  required final JourneyProfileDto journeyProfile,
  required final List<SegmentProfileDto> segmentProfiles,
  required final List<TrainCharacteristicsDto> trainCharacteristics,
  final TestJourneyEvent? journeyEvent,
}) {
  bool validate() =>
      journeyProfile.validate() &&
      segmentProfiles.every((sP) => sP.validate()) &&
      trainCharacteristics.every((tC) => tC.validate()) &&
      (journeyEvent?.payload.validate() ?? true);
}

class const TestJourneyEvent({
  required final String name,
  required final G2bEventPayloadDto payload,
});

extension TestJourneySkeletonX on TestJourneySkeleton {
  TestJourney toTestJourney() {
    final journey = SferaModelMapper.mapToJourney(
      journeyProfile: journeyProfile,
      segmentProfiles: segmentProfiles,
      trainCharacteristics: trainCharacteristics,
      relatedTrainInformation: journeyEvent?.payload.relatedTrainInformation,
    );
    return TestJourney(
      journey: journey,
      name: journeyName,
      eventName: journeyEvent?.name,
      skeleton: this,
    );
  }
}
