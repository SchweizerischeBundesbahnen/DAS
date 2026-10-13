import 'package:sfera/src/data/dto/segment_profile_dto.dart';

const int segmentProfileOrderSize = 100000;

int calculateOrder(int segmentIndex, double location) {
  return (segmentIndex * segmentProfileOrderSize + location).toInt();
}

typedef KilometreMap = Map<double, List<double>>;

KilometreMap parseKilometre(SegmentProfileDto segmentProfile) {
  final kilometreMap = <double, List<double>>{};
  if (segmentProfile.contextInformation != null) {
    for (final kilometreReferencePoint in segmentProfile.contextInformation!.kilometreReferencePoints) {
      if (!kilometreMap.containsKey(kilometreReferencePoint.location)) {
        kilometreMap[kilometreReferencePoint.location] = [];
      }
      kilometreMap[kilometreReferencePoint.location]!.add(kilometreReferencePoint.kmReference.kmRef);
    }
  }
  return kilometreMap;
}
